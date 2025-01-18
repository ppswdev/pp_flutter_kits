import 'ndt7_service_platform_interface.dart';

class Ndt7Service {
  Future<String?> getPlatformVersion() {
    return Ndt7ServicePlatform.instance.getPlatformVersion();
  }

  Future<void> loadServers() {
    return Ndt7ServicePlatform.instance.loadServers();
  }

  Future<void> startTest({int index = 0}) {
    return Ndt7ServicePlatform.instance.startTest(index);
  }

  Future<void> stopTest() {
    return Ndt7ServicePlatform.instance.stopTest();
  }

  Stream<(String, Map<String, dynamic>)> get onNDTServiceEvents {
    return Ndt7ServicePlatform.instance.onEventStream
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
}
