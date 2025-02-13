import Flutter
import UIKit

public class AudioEnginePlayerPlugin: NSObject, FlutterPlugin {
    private var audioEnginePlayer = AudioEnginePlayer()
    private var eventSink: FlutterEventSink?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "audio_engine_player", binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel(name: "audio_engine_player_events", binaryMessenger: registrar.messenger())
        let instance = AudioEnginePlayerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        eventChannel.setStreamHandler(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "duration":
            let value = audioEnginePlayer.totalDuration
            result(value)
        case "volume":
            let value = audioEnginePlayer.volume
            result(value)
        case "isMute":
            let value = audioEnginePlayer.isMute
            result(value)
        case "enableFadeEffect":
            let value = audioEnginePlayer.enableFadeEffect
            result(value)
        case "speed":
            let value = audioEnginePlayer.speed
            result(value)
        case "currentPlayIndex":
            let currentPlayIndex = audioEnginePlayer.currentPlayIndex
            result(currentPlayIndex)
        case "isPlaying":
            let isPlaying = audioEnginePlayer.isPlaying
            result(isPlaying)
        case "ensureEngineRunning":
            audioEnginePlayer.ensureEngineRunning()
            result(nil)
        case "playWith":
            if let args = call.arguments as? [String: Any],
               let filePath = args["filePath"] as? String,
               let title = args["title"] as? String,
               let artist = args["artist"] as? String,
               let album = args["album"] as? String {
                var track = TrackModel(source: filePath, title: title, artist: artist, album: album, albumArt: nil)
                if let base64String = args["albumArt"] as? String, base64String.count > 0, let imageData = Data(base64Encoded: base64String), let image = UIImage(data: imageData) {
                    track.albumArt = image
                }
                audioEnginePlayer.play(with: track)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "filePath, title, artist, and album are required", details: nil))
            }
        case "seekTo":
            if let args = call.arguments as? [String: Any], let milliseconds = args["milliseconds"] as? Int {
                audioEnginePlayer.seekTo(milliseconds: milliseconds)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "milliseconds is required", details: nil))
            }
        case "seekToIndex":
            if let args = call.arguments as? [String: Any], let index = args["index"] as? Int {
                audioEnginePlayer.seekToIndex(index);
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "milliseconds is required", details: nil))
            }
        case "playOrPause":
            audioEnginePlayer.playOrPause()
            result(nil)
        case "play":
            audioEnginePlayer.play()
            result(nil)
        case "pause":
            audioEnginePlayer.pause()
            result(nil)
        case "stop":
            audioEnginePlayer.stop()
            result(nil)
        case "setPlaylist":
            if let args = call.arguments as? [String: Any], let tracks = args["tracks"] as? [[String: Any]], let autoPlay = args["autoPlay"] as? Bool {
                let trackModels = tracks.compactMap { trackDict -> TrackModel? in
                    guard let source = trackDict["source"] as? String,
                          let title = trackDict["title"] as? String,
                          let artist = trackDict["artist"] as? String,
                          let album = trackDict["album"] as? String else {
                        return nil
                    }
                    var track = TrackModel(source: source, title: title, artist: artist, album: album, albumArt: nil)
                    if let base64String = trackDict["albumArt"] as? String, base64String.count > 0, let imageData = Data(base64Encoded: base64String), let image = UIImage(data: imageData) {
                        track.albumArt = image
                    }
                    return track
                }
                audioEnginePlayer.setPlaylist(trackModels, autoPlay: autoPlay)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "tracks and autoPlay are required", details: nil))
            }
        case "updatePlaylistInfos":
            if let args = call.arguments as? [String: Any], let tracks = args["tracks"] as? [[String: Any]] {
                let trackModels = tracks.compactMap { trackDict -> TrackModel? in
                    guard let source = trackDict["source"] as? String,
                          let title = trackDict["title"] as? String,
                          let artist = trackDict["artist"] as? String,
                          let album = trackDict["album"] as? String else {
                        return nil
                    }
                    var track = TrackModel(source: source, title: title, artist: artist, album: album, albumArt: nil)
                    if let base64String = trackDict["albumArt"] as? String, base64String.count > 0, let imageData = Data(base64Encoded: base64String), let image = UIImage(data: imageData) {
                        track.albumArt = image
                    }
                    return track
                }
                audioEnginePlayer.updatePlaylistInfos(trackModels)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "tracks and autoPlay are required", details: nil))
            }
        case "appendToPlaylist":
            if let args = call.arguments as? [String: Any],
               let source = args["source"] as? String,
               let title = args["title"] as? String,
               let artist = args["artist"] as? String,
               let album = args["album"] as? String,
               let autoPlay = args["autoPlay"] as? Bool {
                var track = TrackModel(source: source, title: title, artist: artist, album: album, albumArt: nil)
                if let base64String = args["albumArt"] as? String, base64String.count > 0, let imageData = Data(base64Encoded: base64String), let image = UIImage(data: imageData) {
                    track.albumArt = image
                }
                audioEnginePlayer.appendToPlaylist(track, autoPlay: autoPlay)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "source, title, artist, album, and autoPlay are required", details: nil))
            }
        case "removeFromPlaylist":
            if let args = call.arguments as? [String: Any], let index = args["index"] as? Int {
                audioEnginePlayer.removeFromPlaylist(index)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "url and autoPlay are required", details: nil))
            }
        case "moveOnPlaylist":
            if let args = call.arguments as? [String: Any], let oldIndex = args["oldIndex"] as? Int, let newIndex = args["newIndex"] as? Int {
                audioEnginePlayer.moveOnPlaylist(oldIndex, newIndex);
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "url and autoPlay are required", details: nil))
            }
        case "playNext":
            audioEnginePlayer.playNext()
            result(nil)
        case "playPrevious":
            audioEnginePlayer.playPrevious()
            result(nil)
        case "setSpeed":
            if let args = call.arguments as? [String: Any], let value = args["speed"] as? Float {
                audioEnginePlayer.setSpeed(value)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "speed is required", details: nil))
            }
        case "setVolume":
            if let args = call.arguments as? [String: Any], let volume = args["volume"] as? Float {
                audioEnginePlayer.setVolume(volume)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "volume is required", details: nil))
            }
        case "setVolumeBoost":
            if let args = call.arguments as? [String: Any], let value = args["gain"] as? Float {
                audioEnginePlayer.setVolumeBoost(value)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "volume is required", details: nil))
            }
        case "setMute":
            if let args = call.arguments as? [String: Any], let value = args["isMute"] as? Bool {
                audioEnginePlayer.setIsMute(value)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "isMute is required", details: nil))
            }
        case "setEnableFadeEffect":
            if let args = call.arguments as? [String: Any], let value = args["enableFadeEffect"] as? Bool {
                audioEnginePlayer.setEnableFadeEffect(value)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "isMute is required", details: nil))
            }
        case "setLoopMode":
            if let args = call.arguments as? [String: Any], let mode = args["mode"] as? Int {
                let loopMode: LoopMode
                switch mode {
                case 0:
                    loopMode = .all
                case 1:
                    loopMode = .single
                case 2:
                    loopMode = .shuffle
                default:
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid loop mode", details: nil))
                    return
                }
                audioEnginePlayer.setLoopMode(loopMode)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "mode is required", details: nil))
            }
        case "setBandGain":
            if let args = call.arguments as? [String: Any], let bandIndex = args["bandIndex"] as? Int, let gain = args["gain"] as? Float {
                audioEnginePlayer.setBandGain(bandIndex: bandIndex, gain: gain)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "bandIndex and gain are required", details: nil))
            }
        case "setReverb":
            if let args = call.arguments as? [String: Any], let id = args["id"] as? Int, let wetDryMix = args["wetDryMix"] as? Float {
                audioEnginePlayer.setReverb(id: id, wetDryMix: wetDryMix)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "id and wetDryMix are required", details: nil))
            }
        case "resetAll":
            audioEnginePlayer.resetAll()
            result(nil)
        case "clearCaches":
            audioEnginePlayer.clearCaches()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func setupCallbacks() {
        audioEnginePlayer.onPlayingStatusChanged = { [weak self] isPlaying in
            guard let self = self, let eventSink = self.eventSink else { return }
            eventSink(["event": "playingStatus", "isPlaying": isPlaying])
        }
        
        audioEnginePlayer.onPlayingIndexChanged = { [weak self] index in
            guard let self = self, let eventSink = self.eventSink else { return }
            eventSink(["event": "playingIndex", "currentIndex": index])
        }
        
        audioEnginePlayer.onPlaybackProgressUpdate = { [weak self] progress in
            guard let self = self, let eventSink = self.eventSink else { return }
            eventSink(["event": "playbackProgress", "progress": progress, "duration": self.audioEnginePlayer.totalDuration])
        }
        
        audioEnginePlayer.onPlayCompleted = { [weak self] in
            guard let self = self, let eventSink = self.eventSink else { return }
            eventSink(["event": "playCompleted", "isCompleted": true])
        }
    }
}

extension AudioEnginePlayerPlugin: FlutterStreamHandler {
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
