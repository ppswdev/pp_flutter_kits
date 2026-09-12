# PPIntl

Ein schlankes Flutter-Paket für Internationalisierung mit gebündelten Übersetzungen für 18 Sprachen.

## Installation

Fügen Sie das Paket zu `pubspec.yaml` hinzu und führen Sie anschließend Folgendes aus:

\`\`\`yaml
dependencies:
  pp_intl: ^1.1.1
\`\`\`

\`\`\`bash
flutter pub get
\`\`\`

## Sprachkonfiguration

Verwenden Sie die unterstützten Sprachcodes mit `setLanguage`, `text` oder `textSync`. Groß- und Kleinschreibung wird ignoriert.

`ar`, `de`, `en`, `es`, `fil`, `fr`, `id`, `it`, `ja`, `ko`, `pl`, `pt`, `ru`, `th`, `tr`, `vi`, `zh_hans`, `zh_hant`

\`\`\`dart
import 'package:pp_intl/pp_intl.dart';

await PPIntl.instance.setLanguage('de');
\`\`\`

## Verwendung

Verwenden Sie die asynchrone API, wenn eine Sprache erstmals geladen wird.

\`\`\`dart
final greeting = await PPIntl.text(
  PPIntlKey.helloName,
  params: {'value': 'Taylor'},
);
\`\`\`

Verwenden Sie die synchrone API erst, nachdem die Sprache geladen wurde.

\`\`\`dart
await PPIntl.instance.setLanguage('de');
final greeting = PPIntl.textSync(PPIntlKey.hello);
\`\`\`

## Vollständige Referenz

Alle Schlüssel, Beispiele und Hinweise zur Leistung finden Sie im englischen Leitfaden.

[README.md](README.md)

## License

MIT

