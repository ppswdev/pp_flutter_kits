# PPIntl

18 言語の翻訳を同梱した、軽量な Flutter 国際化パッケージです。

## インストール

`pubspec.yaml` にパッケージを追加してから、次を実行します。

\`\`\`yaml
dependencies:
  pp_intl: ^1.1.1
\`\`\`

\`\`\`bash
flutter pub get
\`\`\`

## 言語設定

`setLanguage`、`text`、`textSync` では対応する言語コードを使用します。コードの大文字・小文字は区別されません。

`ar`, `de`, `en`, `es`, `fil`, `fr`, `id`, `it`, `ja`, `ko`, `pl`, `pt`, `ru`, `th`, `tr`, `vi`, `zh_hans`, `zh_hant`

\`\`\`dart
import 'package:pp_intl/pp_intl.dart';

await PPIntl.instance.setLanguage('ja');
\`\`\`

## 使い方

言語を初めて読み込むときは非同期 API を使用します。

\`\`\`dart
final greeting = await PPIntl.text(
  PPIntlKey.helloName,
  params: {'value': 'Taylor'},
);
\`\`\`

同期 API は言語を読み込んだ後にのみ使用してください。

\`\`\`dart
await PPIntl.instance.setLanguage('ja');
final greeting = PPIntl.textSync(PPIntlKey.hello);
\`\`\`

## 完全なリファレンス

すべてのキー、例、パフォーマンスに関する注意事項は英語版ガイドを参照してください。

[README.md](README.md)

## License

MIT

