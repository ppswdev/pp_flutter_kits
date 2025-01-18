package com.ppsw.tech.audio_engine_player

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** AudioEnginePlayerPlugin */
class AudioEnginePlayerPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel : MethodChannel
  private val audioEnginePlayer = AudioEnginePlayer()

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "audio_engine_player")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
      "getTotalDuration" -> result.success(audioEnginePlayer.totalDuration)
      "getVolume" -> result.success(audioEnginePlayer.volume)
      "play" -> {
        val filePath = call.argument<String>("filePath")
        if (filePath != null) {
          audioEnginePlayer.play(filePath)
          result.success(null)
        } else {
          result.error("INVALID_ARGUMENT", "filePath is required", null)
        }
      }
      "seekTo" -> {
        val milliseconds = call.argument<Int>("milliseconds")
        if (milliseconds != null) {
          audioEnginePlayer.seekTo(milliseconds)
          result.success(null)
        } else {
          result.error("INVALID_ARGUMENT", "milliseconds is required", null)
        }
      }
      "playOrPause" -> {
        audioEnginePlayer.playOrPause()
        result.success(null)
      }
      "stop" -> {
        audioEnginePlayer.stop()
        result.success(null)
      }
      "setPlaylist" -> {
        val urls = call.argument<List<String>>("urls")
        val autoPlay = call.argument<Boolean>("autoPlay") ?: false
        if (urls != null) {
          audioEnginePlayer.setPlaylist(urls, autoPlay)
          result.success(null)
        } else {
          result.error("INVALID_ARGUMENT", "urls and autoPlay are required", null)
        }
      }
      "appendToPlaylist" -> {
        val url = call.argument<String>("url")
        val autoPlay = call.argument<Boolean>("autoPlay") ?: false
        if (url != null) {
          audioEnginePlayer.appendToPlaylist(url, autoPlay)
          result.success(null)
        } else {
          result.error("INVALID_ARGUMENT", "url and autoPlay are required", null)
        }
      }
      "playNext" -> {
        audioEnginePlayer.playNext()
        result.success(null)
      }
      "playPrevious" -> {
        audioEnginePlayer.playPrevious()
        result.success(null)
      }
      "setVolume" -> {
        val volume = call.argument<Float>("volume")
        if (volume != null) {
          audioEnginePlayer.setVolume(volume)
          result.success(null)
        } else {
          result.error("INVALID_ARGUMENT", "volume is required", null)
        }
      }
      "setLoopMode" -> {
        val mode = call.argument<Int>("mode")
        if (mode != null) {
          val loopMode = when (mode) {
            0 -> LoopMode.ALL
            1 -> LoopMode.SINGLE
            2 -> LoopMode.SHUFFLE
            else -> {
              result.error("INVALID_ARGUMENT", "Invalid loop mode", null)
              return
            }
          }
          audioEnginePlayer.setLoopMode(loopMode)
          result.success(null)
        } else {
          result.error("INVALID_ARGUMENT", "mode is required", null)
        }
      }
      "setBandGain" -> {
        val bandIndex = call.argument<Int>("bandIndex")
        val gain = call.argument<Float>("gain")
        if (bandIndex != null && gain != null) {
          audioEnginePlayer.setBandGain(bandIndex, gain)
          result.success(null)
        } else {
          result.error("INVALID_ARGUMENT", "bandIndex and gain are required", null)
        }
      }
      "setReverb" -> {
        val id = call.argument<Int>("id")
        val wetDryMix = call.argument<Float>("wetDryMix")
        if (id != null && wetDryMix != null) {
          audioEnginePlayer.setReverb(id, wetDryMix)
          result.success(null)
        } else {
          result.error("INVALID_ARGUMENT", "id and wetDryMix are required", null)
        }
      }
      "resetAll" -> {
        audioEnginePlayer.resetAll()
        result.success(null)
      }
      "clearCaches" -> {
        audioEnginePlayer.clearCaches()
        result.success(null)
      }
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}