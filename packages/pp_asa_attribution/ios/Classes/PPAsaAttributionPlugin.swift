import Flutter
import UIKit

public class PPAsaAttributionPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "pp_asa_attribution", binaryMessenger: registrar.messenger())
        let instance = PPAsaAttributionPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)

        case "attributionToken":
            if let token = AsaManager.attributionToken() {
                result(token)
            } else {
                result("")
            }
        case "requestAttributionWithToken":
            if let args = call.arguments as? [String: Any],
                let token = args["token"] as? String
            {
                AsaManager.requestAttribution(withToken: token) { data, error in
                    if let attributionData = data {
                        result(attributionData)
                    } else {
                        result(["error": "attributionData is null"])
                    }
                }
            } else {
                result(["error": "Parameter Token is required"])
            }
        case "requestAttributionDetails":
            AsaManager.requestAttribution { data, error in
                if let attributionData = data {
                    result(attributionData)
                } else {
                    result(["error": error?.localizedDescription ?? "Unknown error"])
                }
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
