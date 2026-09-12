# PPIntl

Lekki pakiet internacjonalizacji Flutter z wbudowanymi tłumaczeniami dla 18 języków.

## Instalacja

Dodaj pakiet do `pubspec.yaml`, a następnie uruchom:

\`\`\`yaml
dependencies:
  pp_intl: ^1.1.1
\`\`\`

\`\`\`bash
flutter pub get
\`\`\`

## Konfiguracja języka

Używaj obsługiwanych kodów języków z `setLanguage`, `text` lub `textSync`. Wielkość liter nie ma znaczenia.

`ar`, `de`, `en`, `es`, `fil`, `fr`, `id`, `it`, `ja`, `ko`, `pl`, `pt`, `ru`, `th`, `tr`, `vi`, `zh_hans`, `zh_hant`

\`\`\`dart
import 'package:pp_intl/pp_intl.dart';

await PPIntl.instance.setLanguage('pl');
\`\`\`

## Użycie

Używaj asynchronicznego API podczas pierwszego ładowania języka.

\`\`\`dart
final greeting = await PPIntl.text(
  PPIntlKey.helloName,
  params: {'value': 'Taylor'},
);
\`\`\`

Używaj synchronicznego API dopiero po załadowaniu języka.

\`\`\`dart
await PPIntl.instance.setLanguage('pl');
final greeting = PPIntl.textSync(PPIntlKey.hello);
\`\`\`

## Pełna dokumentacja

Pełną listę kluczy, przykłady i uwagi o wydajności znajdziesz w angielskim przewodniku.

[README.md](README.md)

## License

MIT

