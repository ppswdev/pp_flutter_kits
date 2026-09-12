# PPIntl

Лёгкий пакет интернационализации Flutter со встроенными переводами для 18 языков.

## Установка

Добавьте пакет в `pubspec.yaml`, затем выполните:

\`\`\`yaml
dependencies:
  pp_intl: ^1.1.1
\`\`\`

\`\`\`bash
flutter pub get
\`\`\`

## Настройка языка

Используйте поддерживаемые коды языков с `setLanguage`, `text` или `textSync`. Регистр символов не имеет значения.

`ar`, `de`, `en`, `es`, `fil`, `fr`, `id`, `it`, `ja`, `ko`, `pl`, `pt`, `ru`, `th`, `tr`, `vi`, `zh_hans`, `zh_hant`

\`\`\`dart
import 'package:pp_intl/pp_intl.dart';

await PPIntl.instance.setLanguage('ru');
\`\`\`

## Использование

Используйте асинхронный API при первой загрузке языка.

\`\`\`dart
final greeting = await PPIntl.text(
  PPIntlKey.helloName,
  params: {'value': 'Taylor'},
);
\`\`\`

Используйте синхронный API только после загрузки языка.

\`\`\`dart
await PPIntl.instance.setLanguage('ru');
final greeting = PPIntl.textSync(PPIntlKey.hello);
\`\`\`

## Полная справка

Полный список ключей, примеры и примечания о производительности доступны в английском руководстве.

[README.md](README.md)

## License

MIT

