import 'pp_shazam_kit_platform_interface.dart';

enum RecognizeState { idle, listening, recognizing }

class MusicRecognitionResult {
  final String? title;
  final String? artist;
  final String? album;
  final List<String> genres;
  final String? releaseDate;
  final String? artworkURL;
  final String? webURL;
  final String? appleMusicURL;
  final String? videoURL;

  MusicRecognitionResult({
    this.title,
    this.artist,
    this.album,
    this.genres = const [],
    this.releaseDate,
    this.artworkURL,
    this.webURL,
    this.appleMusicURL,
    this.videoURL,
  });

  factory MusicRecognitionResult.fromJson(Map<String, dynamic> json) {
    return MusicRecognitionResult(
      title: json['title'] as String?,
      artist: json['artist'] as String?,
      album: json['album'] as String?,
      genres:
          (json['genres'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      releaseDate: json['releaseDate'] as String?,
      artworkURL: json['artworkURL'] as String?,
      webURL: json['webURL'] as String?,
      appleMusicURL: json['appleMusicURL'] as String?,
      videoURL: json['videoURL'] as String?,
    );
  }
}

class PPShazamKit {
  Future<String?> getPlatformVersion() {
    return PPShazamKitPlatform.instance.getPlatformVersion();
  }

  Stream<(String, Map<String, dynamic>)> get onMusicRecognitionEvents {
    return PPShazamKitPlatform.instance.onEventStream
        .where((event) => event['event'] != null)
        .map((event) {
          try {
            final eventType = event['event'] as String;
            final eventData = Map<String, dynamic>.from(event)..remove('event');
            return (eventType, eventData);
          } catch (e) {
            return ('error', {'desc': e.toString()});
          }
        });
  }

  Future<void> startRecognize() {
    return PPShazamKitPlatform.instance.startRecognize();
  }

  Future<void> stopRecognize() {
    return PPShazamKitPlatform.instance.stopRecognize();
  }
}
