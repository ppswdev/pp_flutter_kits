import 'package:flutter/services.dart';

class CommonUtil {
  static copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }
}
