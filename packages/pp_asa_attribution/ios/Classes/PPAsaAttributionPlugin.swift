import Flutter
import UIKit

public class PPAsaAttributionPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "pp_asa_attribution", binaryMessenger: registrar.messenger())
    let instance = PPAsaAttributionPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
        result("iOS " + UIDevice.current.systemVersion)
    case "requestAttributionDetails":
        AsaManager.requestAttribution { data, error in
            if let attributionData = data {
                result(attributionData)
            } else {
                result(FlutterError(code: "FAILED",  message: "requestAttribution error",  details: nil))
            }
        }
    case "attributionToken":
        result(AsaManager.attributionToken())
    default:
        result(FlutterMethodNotImplemented)
    }
  }
}
