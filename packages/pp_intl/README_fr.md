# PPIntl

Un package Flutter léger d’internationalisation avec des traductions intégrées pour 18 langues.

## Installation

Ajoutez le package à `pubspec.yaml`, puis exécutez :

\`\`\`yaml
dependencies:
  pp_intl: ^1.1.1
\`\`\`

\`\`\`bash
flutter pub get
\`\`\`

## Configuration de la langue

Utilisez les codes de langue pris en charge avec `setLanguage`, `text` ou `textSync`. La casse est ignorée.

`ar`, `de`, `en`, `es`, `fil`, `fr`, `id`, `it`, `ja`, `ko`, `pl`, `pt`, `ru`, `th`, `tr`, `vi`, `zh_hans`, `zh_hant`

\`\`\`dart
import 'package:pp_intl/pp_intl.dart';

await PPIntl.instance.setLanguage('fr');
\`\`\`

## Utilisation

Utilisez l’API asynchrone lorsqu’une langue est chargée pour la première fois.

\`\`\`dart
final greeting = await PPIntl.text(
  PPIntlKey.helloName,
  params: {'value': 'Taylor'},
);
\`\`\`

Utilisez l’API synchrone uniquement après le chargement de la langue.

\`\`\`dart
await PPIntl.instance.setLanguage('fr');
final greeting = PPIntl.textSync(PPIntlKey.hello);
\`\`\`

## Référence complète

Consultez le guide anglais pour toutes les clés, les exemples et les notes de performance.

[README.md](README.md)

## License

MIT

