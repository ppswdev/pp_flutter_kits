import 'dart:convert';

extension MapExtension on Map<String, dynamic> {
  String toJsonString() {
    return jsonEncode(this);
  }
}
