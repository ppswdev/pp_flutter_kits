import Flutter
import UIKit

public class Ndt7ServicePlugin: NSObject, FlutterPlugin {
  private var service = NDTService()
  private var eventSink: FlutterEventSink?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "ndt7_service", binaryMessenger: registrar.messenger())
    let eventChannel = FlutterEventChannel(name: "ndt7_service_events", binaryMessenger: registrar.messenger())
    let instance = Ndt7ServicePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    eventChannel.setStreamHandler(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "loadServers":
      service.loadServers()
      result("loadServers run")
    case "startTest":
      if let args = call.arguments as? [String: Any], let serverIndex = args["index"] as? Int {
          service.startTest(serverIndex)
          result("startTest run")
      } else {
          result("startTest error")
      }
    case "stopTest":
      service.stopTest()
      result("stopTest run")
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func setupCallbacks() {
      service.serversLoadedClosure = { [weak self] servers in
          guard let self = self, let eventSink = self.eventSink else { return }
          DispatchQueue.main.async {
              eventSink(["event": "onServersLoaded", "servers": servers])
          }
      }

      service.testClosure = { [weak self] kind, running in
          guard let self = self, let eventSink = self.eventSink else { return }
          DispatchQueue.main.async {
              eventSink(["event": "onTestUpdate", "kind": kind, "running": running])
          }
      }

      service.measurementClosure = { [weak self] origin, kind, measurement in
          guard let self = self, let eventSink = self.eventSink else { return }
          DispatchQueue.main.async {
              eventSink(["event": "onMeasurementUpdate", "origin": origin, "kind": kind, "measurement": measurement])
          }
      }

      service.errorClosure = { [weak self] kind, eStr in
          guard let self = self, let eventSink = self.eventSink else { return }
          DispatchQueue.main.async {
              eventSink(["event": "onError", "kind": kind, "str": eStr])
          }
      }
  }
}

extension Ndt7ServicePlugin: FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        setupCallbacks()
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}