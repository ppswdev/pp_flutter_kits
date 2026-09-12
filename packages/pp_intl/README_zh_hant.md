# PPIntl

輕量的 Flutter 國際化套件，內建 18 種語言的翻譯。

## 安裝

將套件加入 `pubspec.yaml`，然後執行：

\`\`\`yaml
dependencies:
  pp_intl: ^1.1.1
\`\`\`

\`\`\`bash
flutter pub get
\`\`\`

## 語言設定

請在 `setLanguage`、`text` 或 `textSync` 中使用支援的語言代碼。代碼不區分大小寫。

`ar`, `de`, `en`, `es`, `fil`, `fr`, `id`, `it`, `ja`, `ko`, `pl`, `pt`, `ru`, `th`, `tr`, `vi`, `zh_hans`, `zh_hant`

\`\`\`dart
import 'package:pp_intl/pp_intl.dart';

await PPIntl.instance.setLanguage('zh_hant');
\`\`\`

## 使用方式

首次載入語言時，請使用非同步 API。

\`\`\`dart
final greeting = await PPIntl.text(
  PPIntlKey.helloName,
  params: {'value': 'Taylor'},
);
\`\`\`

請在語言載入完成後再使用同步 API。

\`\`\`dart
await PPIntl.instance.setLanguage('zh_hant');
final greeting = PPIntl.textSync(PPIntlKey.hello);
\`\`\`

## 完整參考

所有鍵值、範例與效能注意事項請參閱英文指南。

[README.md](README.md)

## License

MIT

