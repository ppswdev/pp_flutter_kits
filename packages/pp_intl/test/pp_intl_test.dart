import 'package:flutter_test/flutter_test.dart';

import 'package:pp_intl/pp_intl.dart';

void main() {
  test('returns English translation by default', () async {
    expect(await PPIntl.text(PPIntlKey.hello, 'en'), 'Hello');
  });

  test('returns Arabic translation for ar', () async {
    expect(await PPIntl.text(PPIntlKey.hello, 'ar'), 'مرحبا');
  });

  test('returns German translation for de', () async {
    expect(await PPIntl.text(PPIntlKey.hello, 'de'), 'Hallo');
  });

  test('returns Spanish translation for es', () async {
    expect(await PPIntl.text(PPIntlKey.hello, 'es'), 'Hola');
  });

  test('returns Filipino translation for fil', () async {
    expect(await PPIntl.text(PPIntlKey.hello, 'fil'), 'Kamusta');
  });

  test('returns French translation for fr', () async {
    expect(await PPIntl.text(PPIntlKey.hello, 'fr'), 'Bonjour');
  });

  test('returns Indonesian translation for id', () async {
    expect(await PPIntl.text(PPIntlKey.hello, 'id'), 'Halo');
  });

  test('returns Italian translation for it', () async {
    expect(await PPIntl.text(PPIntlKey.hello, 'it'), 'Ciao');
  });

  test('returns Japanese translation for ja', () async {
    expect(await PPIntl.text(PPIntlKey.hello, 'ja'), 'こんにちは');
  });

  test('returns Korean translation for ko', () async {
    expect(await PPIntl.text(PPIntlKey.hello, 'ko'), '안녕하세요');
  });

  test('returns Polish translation for pl', () async {
    expect(await PPIntl.text(PPIntlKey.hello, 'pl'), 'Cześć');
  });

  test('returns Portuguese translation for pt', () async {
    expect(await PPIntl.text(PPIntlKey.hello, 'pt'), 'Olá');
  });

  test('returns Russian translation for ru', () async {
    expect(await PPIntl.text(PPIntlKey.hello, 'ru'), 'Привет');
  });

  test('returns Thai translation for th', () async {
    expect(await PPIntl.text(PPIntlKey.hello, 'th'), 'สวัสดี');
  });

  test('returns Turkish translation for tr', () async {
    expect(await PPIntl.text(PPIntlKey.hello, 'tr'), 'Merhaba');
  });

  test('returns Vietnamese translation for vi', () async {
    expect(await PPIntl.text(PPIntlKey.hello, 'vi'), 'Xin chào');
  });

  test('returns Simplified Chinese translation for zh_Hans', () async {
    expect(await PPIntl.text(PPIntlKey.hello, 'zh_Hans'), '你好');
  });

  test('returns Traditional Chinese translation for zh_Hant', () async {
    expect(await PPIntl.text(PPIntlKey.hello, 'zh_Hant'), '你好');
  });

  test('returns text with parameters', () async {
    expect(
      await PPIntl.text(PPIntlKey.helloName, 'en', {'name': 'John'}),
      'Hello John',
    );
  });

  test('returns English for unknown language', () async {
    expect(await PPIntl.text(PPIntlKey.hello, 'xx'), 'Hello');
  });

  test('sets and uses default language', () async {
    await PPIntl.instance.setLanguage('fr');
    expect(await PPIntl.text(PPIntlKey.hello), 'Bonjour');
  });
}
