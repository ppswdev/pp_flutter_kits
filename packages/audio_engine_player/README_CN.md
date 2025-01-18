
# audio_engine_player

这是一个基于iOS AVAudioEngine 的音频播放器。目前支持音频文件的播放、暂停、添加播放列表、上一首、下一首、循环模式、额外支持实时均衡器，混响。后续将继续优化更新。

# 快速上手

## 初始化对象

``` dart
final AudioEnginePlayer _audioEnginePlayer = AudioEnginePlayer();
```

## 基本操作

``` dart
_audioEnginePlayer.playPrevious();
_audioEnginePlayer.playOrPause();
_audioEnginePlayer.playNext();
_audioEnginePlayer.setLoopMode(0);
_audioEnginePlayer.setLoopMode(1);
_audioEnginePlayer.setLoopMode(2);
```
