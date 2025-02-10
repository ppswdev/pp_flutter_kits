import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:audio_engine_player/audio_engine_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Audio Engine Player'),
        ),
        body: const AudioControlPanel(),
      ),
    );
  }
}

class AudioControlPanel extends StatefulWidget {
  const AudioControlPanel({super.key});

  @override
  State<AudioControlPanel> createState() => _AudioControlPanelState();
}

class _AudioControlPanelState extends State<AudioControlPanel> {
  final AudioEnginePlayer _audioEnginePlayer = AudioEnginePlayer();
  StreamSubscription? _playerEventsSubscription;
  final List<double> _frequencies = [
    32,
    64,
    125,
    250,
    500,
    1000,
    2000,
    4000,
    8000,
    16000
  ];

  final Map<double, double> _sliderValues = {
    32: 0.0,
    64: 0.0,
    125: 0.0,
    250: 0.0,
    500: 0.0,
    1000: 0.0,
    2000: 0.0,
    4000: 0.0,
    8000: 0.0,
    16000: 0.0,
  };

  int _reverbPreset = 0;
  double _volume = 1.0;
  int _currentPosition = 0;
  int _duration = 0;

  List<Map<String, String>> tracks = [
    {
      'source':
          "http://192.168.1.225/musics/BEYOND%20-%20%E6%B5%B7%E9%98%94%E5%A4%A9%E7%A9%BA.mp3",
      'title': "海阔天空",
      'artist': "BEYOND",
      'album': "乐与怒",
    },
    {
      'source':
          "http://192.168.1.225/musics/%E9%99%88%E4%B9%90%E5%9F%BA%20-%20%E6%9C%88%E5%8D%8A%E5%B0%8F%E5%A4%9C%E6%9B%B2.mp3",
      'title': "月半小夜曲",
      'artist': "陈乐基",
      'album': "月半小夜曲",
    },
    {
      'source':
          "http://192.168.1.225/musics/%E5%A2%A8%E5%B0%94%E6%9C%AC%E7%9A%84%E7%A7%8B%E5%A4%A9.m4a",
      'title': "墨尔本的秋天",
      'artist': "未知艺术家",
      'album': "未知专辑",
    },
    {
      'source':
          "http://192.168.1.225/musics/%E9%82%B5%E5%B8%85-%E6%9A%96%E4%B8%80%E6%9D%AF%E8%8C%B6.mp3",
      'title': "暖一杯茶",
      'artist': "邵帅",
      'album': "暖一杯茶",
    },
    {
      'source':
          "http://192.168.1.225/musics/%E5%A5%A2%E9%A6%99%E5%A4%AB%E4%BA%BA.m4a",
      'title': "奢香夫人",
      'artist': "未知艺术家",
      'album': "未知专辑",
    }
  ];

  @override
  void initState() {
    super.initState();
    _playerEventsSubscription =
        _audioEnginePlayer.onPlayerEvents.listen((event) {
      final eventType = event.$1;
      final eventData = event.$2;

      print('eventType $eventType');
      //print('eventData $eventData');

      if (eventType == 'playbackProgress') {
        _currentPosition = eventData["progress"] as int;
        _duration = eventData["duration"] as int;
        print('$_currentPosition/$_duration');
        setState(() {});
      } else if (eventType == 'playingIndex') {
        final playIndex = eventData["currentIndex"] as int;
        print('playIndex $playIndex');
      } else if (eventType == 'playingStatus') {
        final isPlaying = eventData["isPlaying"] as bool;
        print('isPlaying $isPlaying');
      } else if (eventType == 'playCompleted') {
        print('playCompleted');
      } else if (eventType == 'error') {
        print('Error: ${eventData["desc"]}');
      }
    });
  }

  @override
  void dispose() {
    _playerEventsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 500,
              child: ListView.builder(
                itemCount: _frequencies.length,
                itemBuilder: (context, index) {
                  final frequency = _frequencies[index];
                  return _buildSlider(index, frequency);
                },
              ),
            ),
            _buildVolumeSlider(),
            _buildProgressSlider(),
            Text('Progress: $_currentPosition/$_duration'),
            const SizedBox(height: 20),
            _buildControlButtons(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(int index, double frequency) {
    return Row(
      children: [
        Text(frequency.toString()),
        Expanded(
          child: Slider(
            value: _sliderValues[frequency]!,
            min: -12,
            max: 12,
            onChanged: (value) {
              setState(() {
                _sliderValues[frequency] = value;
              });
              print('EQ: index $index, value $value');
              _audioEnginePlayer.setBandGain(index, value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildControlButtons() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: _onSetPlaylist,
              child: const Text('Fill playlist'),
            ),
            ElevatedButton(
              onPressed: _onNextReverb,
              child: const Text('Next Reverb'),
            ),
            ElevatedButton(
              onPressed: _onReset,
              child: const Text('Restore Deafult'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: _onPrevious,
              child: const Text('Play Previous'),
            ),
            ElevatedButton(
              onPressed: _onPlayPause,
              child: const Text('Play/Pause'),
            ),
            ElevatedButton(
              onPressed: _onNext,
              child: const Text('Play Next'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: _onSingleLoop,
              child: const Text('Single loop'),
            ),
            ElevatedButton(
              onPressed: _onLoop,
              child: const Text('Loop all'),
            ),
            ElevatedButton(
              onPressed: _onShuffle,
              child: const Text('Shuffle'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: _onUpdateMetadata,
              child: const Text('Update Metadata'),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildVolumeSlider() {
    return Row(
      children: [
        const Text('Volume'),
        Expanded(
          child: Slider(
            value: _volume,
            min: 0,
            max: 1,
            onChanged: (value) {
              setState(() {
                _volume = value;
              });
              print('volume: $value');
              _audioEnginePlayer.setVolume(value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSlider() {
    return Row(
      children: [
        Expanded(
          child: Slider(
            value: _currentPosition.toDouble().clamp(0.0, _duration.toDouble()),
            min: 0,
            max: _duration.toDouble(),
            onChanged: (value) {
              setState(() {
                _currentPosition = value.toInt();
              });
              _audioEnginePlayer.seekTo(value.toInt());
            },
          ),
        ),
      ],
    );
  }

  Future<String> loadAlbumArt(String assetPath) async {
    final ByteData bytes = await rootBundle.load(assetPath);
    final Uint8List byteList = bytes.buffer.asUint8List();
    return base64Encode(byteList);
  }

  void _onSetPlaylist() async {
    for (var track in tracks) {
      if (track['title'] == '海阔天空') {
        String assetPath = 'assets/album_art.png';
        track['albumArt'] = await loadAlbumArt(assetPath);
      }
    }
    _audioEnginePlayer.setPlaylist(tracks, true);
  }

  void _onNextReverb() {
    _reverbPreset = (_reverbPreset + 1) % 14;
    print('ReverbPreset : $_reverbPreset');
    _audioEnginePlayer.setReverb(_reverbPreset, 50.0);
  }

  void _onReset() {
    _audioEnginePlayer.resetAll();
    _sliderValues.updateAll((key, value) => 0.0);
    setState(() {});
  }

  void _onPrevious() {
    _audioEnginePlayer.playPrevious();
  }

  void _onPlayPause() {
    _audioEnginePlayer.playOrPause();
  }

  void _onNext() {
    _audioEnginePlayer.playNext();
  }

  void _onLoop() {
    _audioEnginePlayer.setLoopMode(0);
  }

  void _onSingleLoop() {
    _audioEnginePlayer.setLoopMode(1);
  }

  void _onShuffle() {
    _audioEnginePlayer.setLoopMode(2);
  }

  void _onUpdateMetadata() async {
    for (var track in tracks) {
      if (track['title'] == '海阔天空') {
        String assetPath = 'assets/album_art2.png';
        track['albumArt'] = await loadAlbumArt(assetPath);
      }
    }
    _audioEnginePlayer.updatePlaylistInfos(tracks);
  }
}
