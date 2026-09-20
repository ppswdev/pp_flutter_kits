import Flutter
import UIKit

public class PpShazamKitPlugin: NSObject, FlutterPlugin {
  private let shazamManager = ShazamManager()
  private var eventSink: FlutterEventSink?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "pp_shazam_kit", binaryMessenger: registrar.messenger())
    let eventChannel = FlutterEventChannel(
      name: "pp_shazam_kit_events", binaryMessenger: registrar.messenger())
    let instance = PpShazamKitPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    eventChannel.setStreamHandler(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "startRecognize":
      shazamManager.startRecognition()
    case "stopRecognize":
      shazamManager.stopRecognition()
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func setupCallbacks() {
    shazamManager.onMatchFound = { [weak self] result in
      guard let self = self, let eventSink = self.eventSink else { return }

      DispatchQueue.main.async {
        eventSink(["event": "onMatchFound", "match": result.toJSON()])
      }
    }

    shazamManager.onMatchNotFound = { [weak self] error in
      guard let self = self, let eventSink = self.eventSink else { return }
      DispatchQueue.main.async {
        let errorMessage = error?.localizedDescription ?? "未知错误"
        eventSink(["event": "onMatchNotFound", "error": errorMessage])
      }
    }

    shazamManager.onStateChanged = { [weak self] state in
      guard let self = self, let eventSink = self.eventSink else { return }
      switch state {
      case .idle:
        print("识别状态：空闲")
        DispatchQueue.main.async {
          eventSink(["event": "onStateChanged", "state": "idle"])
        }
      case .listening:
        print("识别状态：监听中")
        DispatchQueue.main.async {
          eventSink(["event": "onStateChanged", "state": "listening"])
        }
      case .recognizing:
        print("识别状态：识别中")
        DispatchQueue.main.async {
          eventSink(["event": "onStateChanged", "state": "recognizing"])
        }
      case .error(let message):
        print("识别错误：\(message)")
        DispatchQueue.main.async {
          eventSink(["event": "onError", "error": message])
        }
      }
    }

    shazamManager.onError = { [weak self] error in
      guard let self = self, let eventSink = self.eventSink else { return }
      DispatchQueue.main.async {
        eventSink(["event": "onError", "error": error.localizedDescription])
      }
    }
  }
}

extension PpShazamKitPlugin: FlutterStreamHandler {
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    self.eventSink = events
    setupCallbacks()
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.eventSink = nil
    return nil
  }
}
