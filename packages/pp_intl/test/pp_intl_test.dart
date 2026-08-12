import 'package:flutter_test/flutter_test.dart';

import 'package:pp_intl/pp_intl.dart';

void main() {
  test('returns English translation by default', () async {
    expect(await PPIntl.text(PPIntlKey.hello, languageCode: 'en'), 'Hello');
  });

  test('returns Arabic translation for ar', () async {
    expect(await PPIntl.text(PPIntlKey.hello, languageCode: 'ar'), 'مرحبا');
  });

  test('returns German translation for de', () async {
    expect(await PPIntl.text(PPIntlKey.hello, languageCode: 'de'), 'Hallo');
  });

  test('returns Spanish translation for es', () async {
    expect(await PPIntl.text(PPIntlKey.hello, languageCode: 'es'), 'Hola');
  });

  test('returns Filipino translation for fil', () async {
    expect(await PPIntl.text(PPIntlKey.hello, languageCode: 'fil'), 'Kamusta');
  });

  test('returns French translation for fr', () async {
    expect(await PPIntl.text(PPIntlKey.hello, languageCode: 'fr'), 'Bonjour');
  });

  test('returns Indonesian translation for id', () async {
    expect(await PPIntl.text(PPIntlKey.hello, languageCode: 'id'), 'Halo');
  });

  test('returns Italian translation for it', () async {
    expect(await PPIntl.text(PPIntlKey.hello, languageCode: 'it'), 'Ciao');
  });

  test('returns Japanese translation for ja', () async {
    expect(await PPIntl.text(PPIntlKey.hello, languageCode: 'ja'), 'こんにちは');
  });

  test('returns Korean translation for ko', () async {
    expect(await PPIntl.text(PPIntlKey.hello, languageCode: 'ko'), '안녕하세요');
  });

  test('returns Polish translation for pl', () async {
    expect(await PPIntl.text(PPIntlKey.hello, languageCode: 'pl'), 'Cześć');
  });

  test('returns Portuguese translation for pt', () async {
    expect(await PPIntl.text(PPIntlKey.hello, languageCode: 'pt'), 'Olá');
  });

  test('returns Russian translation for ru', () async {
    expect(await PPIntl.text(PPIntlKey.hello, languageCode: 'ru'), 'Привет');
  });

  test('returns Thai translation for th', () async {
    expect(await PPIntl.text(PPIntlKey.hello, languageCode: 'th'), 'สวัสดี');
  });

  test('returns Turkish translation for tr', () async {
    expect(await PPIntl.text(PPIntlKey.hello, languageCode: 'tr'), 'Merhaba');
  });

  test('returns Vietnamese translation for vi', () async {
    expect(await PPIntl.text(PPIntlKey.hello, languageCode: 'vi'), 'Xin chào');
  });

  test('returns Simplified Chinese translation for zh_Hans', () async {
    expect(await PPIntl.text(PPIntlKey.hello, languageCode: 'zh_Hans'), '你好');
  });

  test('returns Traditional Chinese translation for zh_Hant', () async {
    expect(await PPIntl.text(PPIntlKey.hello, languageCode: 'zh_Hant'), '你好');
  });

  test('returns text with parameters', () async {
    expect(await PPIntl.text(PPIntlKey.helloName, languageCode: 'en', params: {'name': 'John'}), 'Hello John');
  });

  test('returns English for unknown language', () async {
    expect(await PPIntl.text(PPIntlKey.hello, languageCode: 'xx'), 'Hello');
  });

  test('sets and uses default language', () async {
    await PPIntl.instance.setLanguage('fr');
    expect(await PPIntl.text(PPIntlKey.hello), 'Bonjour');
  });
}
