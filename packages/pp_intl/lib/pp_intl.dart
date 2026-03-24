import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'src/pp_intl_key.dart';

export 'src/pp_intl_key.dart';

class PPIntl {
  static PPIntl? _instance;
  final Map<String, Map<PPIntlKey, String>> _translationsCache = {};
  String _currentLanguage = 'en';

  PPIntl._();

  static PPIntl get instance => _instance ??= PPIntl._();

  Future<void> setLanguage(String languageCode) async {
    _currentLanguage = languageCode.toLowerCase();
    await _loadTranslations(_currentLanguage);
  }

  static Future<String> text(
    PPIntlKey key, {
    String? languageCode,
    Map<String, dynamic>? params,
  }) async {
    final instance = PPIntl.instance;
    final lang = languageCode?.toLowerCase() ?? instance._currentLanguage;

    // 如果缓存中没有该语言的数据，则异步加载
    if (!instance._translationsCache.containsKey(lang)) {
      await instance._loadTranslations(lang);
    }
    return instance._getTranslatedText(key, lang, params);
  }

  /// 同步获取本地化文本（仅在缓存存在时使用）
  static String textSync(
    PPIntlKey key, {
    String? langCode,
    Map<String, dynamic>? params,
  }) {
    final instance = PPIntl.instance;
    final lang = langCode?.toLowerCase() ?? instance._currentLanguage;
    return instance._getTranslatedText(key, lang, params);
  }

  String _getTranslatedText(
    PPIntlKey key,
    String langCode,
    Map<String, dynamic>? params,
  ) {
    final translations = _translationsCache[langCode];
    var text =
        translations?[key] ?? _translationsCache['en']?[key] ?? 'Unknown';

    if (params != null) {
      params.forEach((key, value) {
        text = text.replaceAll('{$key}', value.toString());
      });
    }

    return text;
  }

  Future<Map<PPIntlKey, String>> _loadTranslations(String languageCode) async {
    if (_translationsCache.containsKey(languageCode)) {
      return _translationsCache[languageCode]!;
    }

    try {
      // 尝试使用包路径加载（发布到 pub.dev 时使用）
      try {
        final jsonString = await rootBundle.loadString(
          'packages/pp_intl/assets/languages/$languageCode.json',
        );
        final jsonMap = json.decode(jsonString) as Map<String, dynamic>;

        final translations = <PPIntlKey, String>{};
        jsonMap.forEach((key, value) {
          final enumKey = PPIntlKey.values.firstWhere(
            (e) => e.toString().split('.').last == key,
            orElse: () => PPIntlKey.hello,
          );
          translations[enumKey] = value.toString();
        });

        _translationsCache[languageCode] = translations;
        return translations;
      } catch (e) {
        // 如果包路径加载失败，尝试使用相对路径（本地开发时使用）
        final jsonString = await rootBundle.loadString(
          'assets/languages/$languageCode.json',
        );
        final jsonMap = json.decode(jsonString) as Map<String, dynamic>;

        final translations = <PPIntlKey, String>{};
        jsonMap.forEach((key, value) {
          final enumKey = PPIntlKey.values.firstWhere(
            (e) => e.toString().split('.').last == key,
            orElse: () => PPIntlKey.hello,
          );
          translations[enumKey] = value.toString();
        });

        _translationsCache[languageCode] = translations;
        return translations;
      }
    } catch (e) {
      //print('Failed to load translations for $languageCode: $e');
      return {};
    }
  }
}
