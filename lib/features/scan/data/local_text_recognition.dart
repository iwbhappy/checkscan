import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Android uses bundled Tesseract models; iOS uses the system Vision engine.
class LocalTextRecognition {
  static const channel = MethodChannel('checkscan/ocr');
  static Future<String>? _initialization;

  static Future<String> _prepareModels() async {
    final root = await getApplicationSupportDirectory();
    final directory = Directory('${root.path}/ocr/tessdata');
    await directory.create(recursive: true);
    for (final language in ['rus', 'kaz', 'eng']) {
      final file = File('${directory.path}/$language.traineddata');
      if (!await file.exists()) {
        final bytes = await rootBundle.load(
          'assets/tessdata/$language.traineddata',
        );
        final temporary = File('${file.path}.tmp');
        await temporary.writeAsBytes(
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
          flush: true,
        );
        await temporary.rename(file.path);
      }
    }
    return '${root.path}/ocr';
  }

  static Future<String> read(String path) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      throw const FormatException(
        'Распознавание фото доступно на Android и iPhone. Текстовый PDF можно импортировать и без OCR.',
      );
    }
    String? dataPath;
    if (Platform.isAndroid) {
      try {
        dataPath = await (_initialization ??= _prepareModels());
      } catch (_) {
        _initialization = null;
        rethrow;
      }
    }
    try {
      return await channel.invokeMethod<String>('recognize', {
            'imagePath': path,
            'dataPath': dataPath,
          }) ??
          '';
    } on PlatformException catch (error) {
      throw FormatException(
        error.message ?? 'Не удалось распознать текст на устройстве',
      );
    }
  }
}
