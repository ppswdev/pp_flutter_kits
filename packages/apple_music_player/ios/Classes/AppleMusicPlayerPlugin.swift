import Flutter
import UIKit
import MediaPlayer

public class AppleMusicPlayerPlugin: NSObject, FlutterPlugin {
    private let musicPlayer = AppleMusicPlayer()
    private var eventSink: FlutterEventSink?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "apple_music_player", binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel(name: "apple_music_player_events", binaryMessenger: registrar.messenger())
        let instance = AppleMusicPlayerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        eventChannel.setStreamHandler(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "syncAllMusic":
            musicPlayer.syncAllMusic()
        case "openMediaPicker":
            DispatchQueue.main.async { [weak self] in
                if let viewController = UIApplication.shared.keyWindow?.rootViewController {
                    print("openMediaPicker success")
                    self?.musicPlayer.openMediaPicker(from: viewController)
                } else {
                    print("openMediaPicker error")
                    result(FlutterError(code: "NO_VIEWCONTROLLER", message: "无法获取当前视图控制器", details: nil))
                }
            }
        case "play":
            musicPlayer.play()
        case "pause":
            musicPlayer.pause()
        case "stop":
            musicPlayer.stop()
        case "togglePlayPause":
            musicPlayer.togglePlayPause()
        case "seekToTime":
            if let time = call.arguments as? Double {
                musicPlayer.seekToTime(time)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "参数类型错误，需要Double类型", details: nil))
            }
        case "skipToBeginning":
            musicPlayer.skipToBeginning()
        case "skipToPreviousItem":
            musicPlayer.skipToPreviousItem()
        case "skipToNextItem":
            musicPlayer.skipToNextItem()
        case "setRepeatMode":
            if let mode = call.arguments as? String {
                switch mode {
                case "one":
                    musicPlayer.setRepeatMode(.one)
                case "all":
                    musicPlayer.setRepeatMode(.all)
                case "shuffle":
                    musicPlayer.setRepeatMode(.shuffle)
                default:
                    musicPlayer.setRepeatMode(.none)
                }
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "参数类型错误，需要String类型", details: nil))
            }
        case "playCurrentQueue":
            musicPlayer.playCurrentPlaylist()
        case "playQueue":
            if let persistentIDs = call.arguments as? [String] {
                //musicPlayer.playQueue(persistentIDs)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "参数类型错误，需要[String]类型", details: nil))
            }
        case "playItem":
            if let persistentID = call.arguments as? String {
                if let persistentIDUInt64 = UInt64(persistentID) {
                    musicPlayer.playItem(withID: persistentIDUInt64)
                } else {
                    result(FlutterError(code: "INVALID_PERSISTENT_ID", message: "无法将persistentID转换为UInt64类型", details: nil))
                }
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "参数类型错误，需要String类型", details: nil))
            }
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func setupCallbacks() {
        musicPlayer.onAuth = { [weak self] status in
            guard let self = self, let eventSink = self.eventSink else { return }
            DispatchQueue.main.async {
                eventSink(["event": "onAuth", "status": status])
            }
        }
        
        musicPlayer.onMusicListUpdated = { [weak self] (songsList: [MPMediaItem]) in
            guard let self = self, let eventSink = self.eventSink else { return }
            let songsData = songsList.map { item -> [String: Any] in
                var songDict: [String: Any] = [
                    "persistentID": "\(item.persistentID)",
                    "title": item.title ?? "",
                    "artist": item.artist ?? "",
                    "albumTitle": item.albumTitle ?? "",
                    "albumArtist": item.albumArtist ?? "",
                    "playbackDuration": item.playbackDuration
                ]
                
                if let artwork = item.artwork, let image = artwork.image(at: CGSize(width: 600, height: 600)) {
                    if let imageData = image.pngData() {
                        songDict["artworkData"] = FlutterStandardTypedData(bytes: imageData)
                    }
                }
                
                return songDict
            }
            DispatchQueue.main.async {
                eventSink(["event": "onMusicListUpdated", "songsList": songsData])
            }
        }
        
        musicPlayer.onPlaybackStateChanged = { [weak self] state in
            guard let self = self, let eventSink = self.eventSink else { return }
            // 将MPMusicPlaybackState转换为字符串
            var stateString: String
            switch state {
            case .stopped:
                stateString = "stopped"
            case .playing:
                stateString = "playing"
            case .paused:
                stateString = "paused"
            case .interrupted:
                stateString = "interrupted"
            case .seekingForward:
                stateString = "seekingForward"
            case .seekingBackward:
                stateString = "seekingBackward"
            @unknown default:
                stateString = "unknown"
            }
            DispatchQueue.main.async {
                eventSink(["event": "onPlaybackStateChanged", "state": stateString])
            }
        }
        
        musicPlayer.onPlaybackProgressChanged = { [weak self] currentTime, totalTime in
            guard let self = self, let eventSink = self.eventSink else { return }
            let progress = Float(currentTime / totalTime)
            let currentTimeStr = musicPlayer.formatTime(currentTime)
            let totalTimeStr = musicPlayer.formatTime(totalTime)
            DispatchQueue.main.async {
                eventSink(["event": "onPlaybackProgressUpdate", "progress": progress, "currentTime": currentTime, "totalTime": totalTime, "currentTimeStr": currentTimeStr, "totalTimeStr": totalTimeStr])
            }
        }
        
        musicPlayer.onNowPlayingItemChanged = { [weak self] item in
            guard let self = self, let eventSink = self.eventSink, let item = item else { return }
            var itemData = [
                "persistentID": "\(item.persistentID)",
                "title": item.title ?? "",
                "artist": item.artist ?? "",
                "albumTitle": item.albumTitle ?? "",
                "albumArtist": item.albumArtist ?? "",
                "playbackDuration": item.playbackDuration
            ]
            if let artwork = item.artwork, let image = artwork.image(at: CGSize(width: 600, height: 600)) {
                if let imageData = image.pngData() {
                    itemData["artworkData"] = FlutterStandardTypedData(bytes: imageData)
                }
            }
            DispatchQueue.main.async {
                eventSink(["event": "onNowPlayingItemChanged", "item": itemData])
            }
        }
        
        musicPlayer.onRepeatModeChanged = { [weak self] mode in
            guard let self = self, let eventSink = self.eventSink else { return }
            let modeString: String
            switch mode {
            case .none:
                modeString = "none"
            case .all:
                modeString = "all"
            case .one:
                modeString = "one"
            case .shuffle:
                modeString = "shuffle"
            @unknown default:
                modeString = "unknown"
            }
            DispatchQueue.main.async {
                eventSink(["event": "onRepeatModeChanged", "mode": modeString])
            }
        }
        
        musicPlayer.onError = { [weak self] error in
            guard let self = self, let eventSink = self.eventSink else { return }
            DispatchQueue.main.async {
                eventSink(["event": "onError", "error": error])
            }
        }
    }
}

extension AppleMusicPlayerPlugin: FlutterStreamHandler {
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
