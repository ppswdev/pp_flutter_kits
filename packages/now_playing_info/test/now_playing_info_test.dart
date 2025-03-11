import 'package:flutter_test/flutter_test.dart';
import 'package:now_playing_info/now_playing_info.dart';
import 'package:now_playing_info/now_playing_info_platform_interface.dart';
import 'package:now_playing_info/now_playing_info_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNowPlayingInfoPlatform
    with MockPlatformInterfaceMixin
    implements NowPlayingInfoPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final NowPlayingInfoPlatform initialPlatform = NowPlayingInfoPlatform.instance;

  test('$MethodChannelNowPlayingInfo is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelNowPlayingInfo>());
  });

  test('getPlatformVersion', () async {
    NowPlayingInfo nowPlayingInfoPlugin = NowPlayingInfo();
    MockNowPlayingInfoPlatform fakePlatform = MockNowPlayingInfoPlatform();
    NowPlayingInfoPlatform.instance = fakePlatform;

    expect(await nowPlayingInfoPlugin.getPlatformVersion(), '42');
  });
}
