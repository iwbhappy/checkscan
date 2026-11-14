package kz.checkscan.checkscan

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.googlecode.tesseract.android.TessBaseAPI
import java.io.File
import java.util.concurrent.Executors
import android.content.Intent
import android.net.Uri
import android.os.Build
import java.util.UUID

class MainActivity : FlutterActivity() {
    private val ocrWorker = Executors.newSingleThreadExecutor()
    private val fileWorker = Executors.newSingleThreadExecutor()
    private var incomingChannel: MethodChannel? = null
    private var pendingReceipt: Map<String, String>? = null
    private var receiverReady = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        incomingChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "checkscan/incoming").also { channel ->
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "takeInitial" -> {
                        receiverReady = true
                        result.success(pendingReceipt)
                        pendingReceipt = null
                    }
                    "release" -> {
                        val path = call.argument<String>("path")
                        if (path != null) {
                            val file = File(path).canonicalFile
                            val incoming = File(cacheDir, "checkscan-incoming").canonicalFile
                            if (file.parentFile == incoming) file.delete()
                        }
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        }
        acceptReceipt(intent)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "checkscan/ocr")
            .setMethodCallHandler { call, result ->
                if (call.method != "recognize") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val imagePath = call.argument<String>("imagePath")
                val dataPath = call.argument<String>("dataPath")
                if (imagePath == null || dataPath == null) {
                    result.error("invalid_image", "Не удалось открыть изображение", null)
                    return@setMethodCallHandler
                }
                ocrWorker.execute {
                    val api = TessBaseAPI()
                    try {
                        check(api.init(dataPath, "rus+kaz+eng", TessBaseAPI.OEM_LSTM_ONLY)) {
                            "Не удалось загрузить языковые модели"
                        }
                        api.setPageSegMode(TessBaseAPI.PageSegMode.PSM_SINGLE_BLOCK)
                        api.setVariable("preserve_interword_spaces", "1")
                        api.setImage(File(imagePath))
                        val text = api.utF8Text ?: ""
                        runOnUiThread { result.success(text) }
                    } catch (error: Exception) {
                        runOnUiThread { result.error("ocr_failed", error.message, null) }
                    } finally {
                        api.recycle()
                    }
                }
            }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        acceptReceipt(intent)
    }

    private fun deliverReceipt(receipt: Map<String, String>) {
        runOnUiThread {
            if (receiverReady) incomingChannel?.invokeMethod("receipt", receipt)
            else pendingReceipt = receipt
        }
    }

    private fun acceptReceipt(intent: Intent?) {
        if (intent?.action != Intent.ACTION_SEND) return
        val type = intent.type ?: return
        if (type == "text/plain") {
            val text = intent.getCharSequenceExtra(Intent.EXTRA_TEXT)?.toString()?.take(4096) ?: return
            deliverReceipt(mapOf("text" to text))
            return
        }
        if (!type.startsWith("image/") && type != "application/pdf") return
        val uri = if (Build.VERSION.SDK_INT >= 33) intent.getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java)
            else @Suppress("DEPRECATION") (intent.getParcelableExtra(Intent.EXTRA_STREAM) as? Uri)
        if (uri == null || uri.scheme != "content") return
        fileWorker.execute {
            val directory = File(cacheDir, "checkscan-incoming").apply { mkdirs() }
            directory.listFiles()?.filter { System.currentTimeMillis() - it.lastModified() > 86400000L }?.forEach { it.delete() }
            val file = File(directory, "${UUID.randomUUID()}.${if (type == "application/pdf") "pdf" else "img"}")
            try {
                contentResolver.openInputStream(uri).use { input ->
                    requireNotNull(input)
                    file.outputStream().use { output ->
                        val buffer = ByteArray(16384)
                        var total = 0L
                        while (true) {
                            val count = input.read(buffer)
                            if (count < 0) break
                            total += count
                            require(total <= 32L * 1024 * 1024) { "Файл больше 32 МБ" }
                            output.write(buffer, 0, count)
                        }
                    }
                }
                deliverReceipt(mapOf("path" to file.path))
            } catch (_: Exception) {
                file.delete()
                runOnUiThread { android.widget.Toast.makeText(this, "Не удалось открыть чек. Выберите файл до 32 МБ внутри приложения.", android.widget.Toast.LENGTH_LONG).show() }
            }
        }
    }

    override fun onDestroy() {
        ocrWorker.shutdown()
        fileWorker.shutdown()
        incomingChannel = null
        super.onDestroy()
    }
}
