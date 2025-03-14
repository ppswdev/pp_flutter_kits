import 'package:flutter/material.dart';
import 'dart:async';

import 'package:apple_music_player/apple_music_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apple Music Player Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MusicPlayerPage(),
    );
  }
}

class MusicPlayerPage extends StatefulWidget {
  const MusicPlayerPage({super.key});

  @override
  State<MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  final _appleMusicPlayer = AppleMusicPlayer();
  bool _isAuthorized = false;
  List<MediaItem> _songsList = [];
  MediaItem? _currentSong;
  PlaybackState _playbackState = PlaybackState.stopped;
  double _progress = 0.0;
  double _currentTime = 0.0;
  double _totalTime = 0.0;
  String _currentTimeStr = '';
  String _totalTimeStr = '';
  RepeatMode _repeatMode = RepeatMode.none;
  bool _isLoading = false;
  StreamSubscription? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _setupEventListener();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  void _setupEventListener() {
    _eventSubscription = _appleMusicPlayer.onPlayerEvents.listen((event) {
      final eventType = event.$1;
      final eventData = event.$2;
      print('EventSubscription: $event');
      switch (eventType) {
        case 'onAuth':
          final status = eventData['status'] as int? ?? 0;
          setState(() {
            _isAuthorized = status == 3;
          });
          break;

        case 'onMusicListUpdated':
          final songsList = eventData['songsList'] as List<dynamic>;
          final items = songsList.map((item) {
            final Map<String, dynamic> itemMap =
                Map<String, dynamic>.from(item as Map);
            return MediaItem.fromMap(itemMap);
          }).toList();
          setState(() {
            _songsList = items;
            _isLoading = false;
          });
          _appleMusicPlayer.playCurrentQueue();
          break;
        case 'onPlaybackStateChanged':
          final stateStr = eventData['state'] as String? ?? 'stopped';
          setState(() {
            _playbackState = _stringToPlaybackState(stateStr);
          });
          break;

        case 'onPlaybackProgressUpdate':
          setState(() {
            _progress = eventData['progress'] as double? ?? 0.0;
            _currentTime = eventData['currentTime'] as double? ?? 0.0;
            _totalTime = eventData['totalTime'] as double? ?? 0.0;
            _currentTimeStr = eventData['currentTimeStr'] as String? ?? '';
            _totalTimeStr = eventData['totalTimeStr'] as String? ?? '';
          });
          break;

        case 'onNowPlayingItemChanged':
          if (eventData.containsKey('item')) {
            final Map<String, dynamic> itemMap =
                Map<String, dynamic>.from(eventData['item'] as Map);
            final item = MediaItem.fromMap(itemMap);
            setState(() {
              _currentSong = item;
            });
          } else {
            setState(() {
              _currentSong = null;
            });
          }
          break;

        case 'onRepeatModeChanged':
          final modeStr = eventData['mode'] as String? ?? 'none';
          setState(() {
            _repeatMode = _stringToRepeatMode(modeStr);
          });
          break;

        case 'error':
          final errorMessage = eventData['error'] as String? ?? '未知错误';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('错误: $errorMessage')),
          );
          setState(() {
            _isLoading = false;
          });
          break;
      }
    });
  }

  PlaybackState _stringToPlaybackState(String state) {
    switch (state) {
      case 'playing':
        return PlaybackState.playing;
      case 'paused':
        return PlaybackState.paused;
      default:
        return PlaybackState.stopped;
    }
  }

  RepeatMode _stringToRepeatMode(String mode) {
    switch (mode) {
      case 'one':
        return RepeatMode.one;
      case 'all':
        return RepeatMode.all;
      case 'shuffle':
        return RepeatMode.shuffle;
      default:
        return RepeatMode.none;
    }
  }

  Future<void> _syncAllMusic() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _appleMusicPlayer.syncAllMusic();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('同步音乐失败: $e')),
      );
    }
  }

  void _openMediaPicker() {
    _appleMusicPlayer.openMediaPicker();
  }

  void _playPause() {
    if (_playbackState == PlaybackState.playing) {
      _appleMusicPlayer.pause();
    } else {
      _appleMusicPlayer.play();
    }
  }

  void _changeRepeatMode() {
    RepeatMode newMode;
    switch (_repeatMode) {
      case RepeatMode.none:
        newMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        newMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        newMode = RepeatMode.shuffle;
        break;
      case RepeatMode.shuffle:
        newMode = RepeatMode.none;
        break;
    }
    _appleMusicPlayer.setRepeatMode(newMode);
  }

  String _getRepeatModeText() {
    switch (_repeatMode) {
      case RepeatMode.none:
        return '不循环';
      case RepeatMode.one:
        return '单曲循环';
      case RepeatMode.all:
        return '列表循环';
      case RepeatMode.shuffle:
        return '随机播放';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apple Music Player'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _syncAllMusic,
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: _openMediaPicker,
          ),
        ],
      ),
      body: _isAuthorized
          ? _buildPlayerContent()
          : Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _syncAllMusic,
                    child: const Text('同步音乐'),
                  ),
                  ElevatedButton(
                    onPressed: _openMediaPicker,
                    child: const Text('打开媒体选择器'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPlayerContent() {
    return Column(
      children: [
        // 当前播放信息
        _buildNowPlayingInfo(),

        // 进度条
        _buildProgressBar(),

        // 控制按钮
        _buildControlButtons(),

        // 歌曲列表
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _songsList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('没有找到音乐'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _syncAllMusic,
                            child: const Text('同步音乐'),
                          ),
                        ],
                      ),
                    )
                  : _buildSongsList(),
        ),
      ],
    );
  }

  Widget _buildNowPlayingInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_currentSong != null) ...[
            if (_currentSong!.artworkData != null)
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: MemoryImage(_currentSong!.artworkData!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[300],
                ),
                child:
                    const Icon(Icons.music_note, size: 80, color: Colors.grey),
              ),
            const SizedBox(height: 16),
            Text(
              _currentSong!.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              _currentSong!.artist,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ] else
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[300],
              ),
              child: const Center(
                child: Text(
                  '未播放',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Slider(
            min: 0,
            max: _totalTime,
            value: _currentTime,
            onChanged: (value) {
              print('onChanged: $value');
            },
            onChangeEnd: (value) {
              print('onChangeEnd: $value');
              _appleMusicPlayer.seekToTime(value);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_currentTimeStr),
                Text(_totalTimeStr),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.skip_previous),
            onPressed: () => _appleMusicPlayer.skipToPreviousItem(),
            iconSize: 36,
          ),
          IconButton(
            icon: Icon(
              _playbackState == PlaybackState.playing
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_filled,
            ),
            onPressed: _playPause,
            iconSize: 48,
          ),
          IconButton(
            icon: const Icon(Icons.skip_next),
            onPressed: () => _appleMusicPlayer.skipToNextItem(),
            iconSize: 36,
          ),
          IconButton(
            icon: Icon(_getRepeatModeIcon()),
            onPressed: _changeRepeatMode,
            tooltip: _getRepeatModeText(),
            iconSize: 24,
          ),
        ],
      ),
    );
  }

  IconData _getRepeatModeIcon() {
    switch (_repeatMode) {
      case RepeatMode.none:
        return Icons.repeat;
      case RepeatMode.one:
        return Icons.repeat_one;
      case RepeatMode.all:
        return Icons.repeat;
      case RepeatMode.shuffle:
        return Icons.shuffle;
    }
  }

  Widget _buildSongsList() {
    return ListView.builder(
      itemCount: _songsList.length,
      itemBuilder: (context, index) {
        final song = _songsList[index];
        final isPlaying = _currentSong != null &&
            _currentSong!.persistentID == song.persistentID &&
            _playbackState == PlaybackState.playing;

        return ListTile(
          leading: song.artworkData != null
              ? Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    image: DecorationImage(
                      image: MemoryImage(song.artworkData!),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.grey[300],
                  ),
                  child: const Icon(Icons.music_note, color: Colors.grey),
                ),
          title: Text(
            song.title,
            style: TextStyle(
              fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
              color: isPlaying ? Theme.of(context).primaryColor : null,
            ),
          ),
          subtitle: Text('${song.artist} • ${song.albumTitle}'),
          trailing: isPlaying
              ? const Icon(Icons.volume_up, color: Colors.blue)
              : null,
          onTap: () {
            _appleMusicPlayer.playItem(song.persistentID);
          },
        );
      },
    );
  }
}
