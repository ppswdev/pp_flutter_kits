import Flutter
import MediaPlayer
import UIKit

public class NowPlayingInfoPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "now_playing_info", binaryMessenger: registrar.messenger())
    let instance = NowPlayingInfoPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "updateNowPlayingInfo":
      if let args = call.arguments as? [String: Any],
        let title = args["title"] as? String,
        let artist = args["artist"] as? String
      {
        let album = args["album"] as? String
        let duration = args["duration"] as? Int
        let position = args["position"] as? Int
        let isPlaying = args["isPlaying"] as? Bool ?? false

        var artwork: UIImage?
        if let base64String = args["albumArt"] as? String,
          !base64String.isEmpty,
          let imageData = Data(base64Encoded: base64String)
        {
          artwork = UIImage(data: imageData)
        }

        updateNowPlayingInfo(
          title: title,
          artist: artist,
          album: album,
          artwork: artwork,
          duration: duration,
          position: position,
          isPlaying: isPlaying
        )
        result(true)
      } else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "缺少必要参数", details: nil))
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

extension NowPlayingInfoPlugin {
  private func updateNowPlayingInfo(
    title: String,
    artist: String,
    album: String?,
    artwork: UIImage?,
    duration: Int?,
    position: Int?,
    isPlaying: Bool
  ) {
    var nowPlayingInfo = [String: Any]()
    nowPlayingInfo[MPMediaItemPropertyTitle] = title
    nowPlayingInfo[MPMediaItemPropertyArtist] = artist
    if let album {
      nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = album
    }

    if let artwork {
      nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: artwork.size) { _ in artwork }
    }

    if let position {
      nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = Double(position) / 1000.0
    }

    if let duration {
      nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = Double(duration) / 1000.0
    }

    nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
    MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
  }
}
