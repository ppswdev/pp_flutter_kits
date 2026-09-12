# PPIntl

Isang magaan na Flutter internationalization package na may kasamang mga salin para sa 18 wika.

## Pag-install

Idagdag ang package sa `pubspec.yaml`, pagkatapos ay patakbuhin ang:

\`\`\`yaml
dependencies:
  pp_intl: ^1.1.1
\`\`\`

\`\`\`bash
flutter pub get
\`\`\`

## Pag-configure ng Wika

Gamitin ang mga suportadong language code sa `setLanguage`, `text`, o `textSync`. Hindi mahalaga ang laki ng titik.

`ar`, `de`, `en`, `es`, `fil`, `fr`, `id`, `it`, `ja`, `ko`, `pl`, `pt`, `ru`, `th`, `tr`, `vi`, `zh_hans`, `zh_hant`

\`\`\`dart
import 'package:pp_intl/pp_intl.dart';

await PPIntl.instance.setLanguage('fil');
\`\`\`

## Paggamit

Gamitin ang asynchronous API sa unang pag-load ng wika.

\`\`\`dart
final greeting = await PPIntl.text(
  PPIntlKey.helloName,
  params: {'value': 'Taylor'},
);
\`\`\`

Gamitin lamang ang synchronous API pagkatapos ma-load ang wika.

\`\`\`dart
await PPIntl.instance.setLanguage('fil');
final greeting = PPIntl.textSync(PPIntlKey.hello);
\`\`\`

## Kumpletong Sanggunian

Tingnan ang English guide para sa lahat ng key, halimbawa, at tala sa performance.

[README.md](README.md)

## License

MIT

