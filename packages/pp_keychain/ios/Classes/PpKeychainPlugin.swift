import Flutter
import UIKit

public class PpKeychainPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "pp_keychain", binaryMessenger: registrar.messenger())
    let instance = PpKeychainPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "save":
      handleSave(call: call, result: result)
    case "read":
      handleRead(call: call, result: result)
    case "delete":
      handleDelete(call: call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func handleSave(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? [String: Any],
          let key = arguments["key"] as? String,
          let value = arguments["value"] as? String else {
      result(false)
      return
    }
    let success = KeychainManager.shared.save(key: key, value: value)
    result(success)
  }

  private func handleRead(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? [String: Any],
          let key = arguments["key"] as? String else {
      result(nil)
      return
    }
    let value = KeychainManager.shared.read(key: key)
    result(value)
  }

  private func handleDelete(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? [String: Any],
          let key = arguments["key"] as? String else {
      result(false)
      return
    }
    let success = KeychainManager.shared.delete(key: key)
    result(success)
  }
}
