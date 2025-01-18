package com.ppsw.tech.audio_engine_player

enum class LoopMode {
  ALL, SINGLE, SHUFFLE
}

class AudioEnginePlayer {
  var totalDuration: Long = 0
  var volume: Float = 1.0f

  fun play(filePath: String) {
    // 实现播放逻辑
  }

  fun seekTo(milliseconds: Int) {
    // 实现跳转逻辑
  }

  fun playOrPause() {
    // 实现播放或暂停逻辑
  }

  fun stop() {
    // 实现停止逻辑
  }

  fun setPlaylist(urls: List<String>, autoPlay: Boolean) {
    // 实现设置播放列表逻辑
  }

  fun appendToPlaylist(url: String, autoPlay: Boolean) {
    // 实现追加到播放列表逻辑
  }

  fun playNext() {
    // 实现播放下一首逻辑
  }

  fun playPrevious() {
    // 实现播放上一首逻辑
  }

  fun setVolume(volume: Float) {
    // 实现设置音量逻辑
  }

  fun setLoopMode(loopMode: LoopMode) {
    // 实现设置循环模式逻辑
  }

  fun setBandGain(bandIndex: Int, gain: Float) {
    // 实现设置频段增益逻辑
  }

  fun setReverb(id: Int, wetDryMix: Float) {
    // 实现设置混响逻辑
  }

  fun resetAll() {
    // 实现重置所有设置逻辑
  }

  fun clearCaches() {
    // 实现清除缓存逻辑
  }
}