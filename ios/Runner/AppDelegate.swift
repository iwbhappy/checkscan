import Flutter
import UIKit
import Vision

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "CheckScanOcr") {
      let channel = FlutterMethodChannel(name: "checkscan/ocr", binaryMessenger: registrar.messenger())
      channel.setMethodCallHandler { call, result in
        guard call.method == "recognize" else { result(FlutterMethodNotImplemented); return }
        guard let args = call.arguments as? [String: Any], let path = args["imagePath"] as? String else {
          result(FlutterError(code: "invalid_image", message: "Не удалось открыть изображение", details: nil)); return
        }
        DispatchQueue.global(qos: .userInitiated).async {
          do {
            let request = VNRecognizeTextRequest()
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = false
            if #available(iOS 16.0, *) { request.revision = VNRecognizeTextRequestRevision3 }
            let supported: [String]
            if #available(iOS 15.0, *) {
              supported = try request.supportedRecognitionLanguages()
            } else {
              supported = try VNRecognizeTextRequest.supportedRecognitionLanguages(for: .accurate, revision: request.revision)
            }
            let languages = ["ru-RU", "kk-KZ", "en-US"].filter { supported.contains($0) }
            guard languages.contains("ru-RU") else {
              DispatchQueue.main.async { result(FlutterError(code: "unsupported_language", message: "Для распознавания русского текста обновите iOS до 16 или новее", details: nil)) }; return
            }
            request.recognitionLanguages = languages
            try VNImageRequestHandler(url: URL(fileURLWithPath: path)).perform([request])
            let text = (request.results ?? []).compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
            DispatchQueue.main.async { result(text) }
          } catch {
            DispatchQueue.main.async { result(FlutterError(code: "ocr_failed", message: error.localizedDescription, details: nil)) }
          }
        }
      }
    }
  }
}
