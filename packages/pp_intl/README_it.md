# PPIntl

Un pacchetto Flutter leggero per l’internazionalizzazione con traduzioni integrate per 18 lingue.

## Installazione

Aggiungi il pacchetto a `pubspec.yaml`, quindi esegui:

\`\`\`yaml
dependencies:
  pp_intl: ^1.1.1
\`\`\`

\`\`\`bash
flutter pub get
\`\`\`

## Configurazione della lingua

Usa i codici lingua supportati con `setLanguage`, `text` o `textSync`. Le maiuscole non fanno differenza.

`ar`, `de`, `en`, `es`, `fil`, `fr`, `id`, `it`, `ja`, `ko`, `pl`, `pt`, `ru`, `th`, `tr`, `vi`, `zh_hans`, `zh_hant`

\`\`\`dart
import 'package:pp_intl/pp_intl.dart';

await PPIntl.instance.setLanguage('it');
\`\`\`

## Utilizzo

Usa l’API asincrona quando una lingua viene caricata per la prima volta.

\`\`\`dart
final greeting = await PPIntl.text(
  PPIntlKey.helloName,
  params: {'value': 'Taylor'},
);
\`\`\`

Usa l’API sincrona solo dopo aver caricato la lingua.

\`\`\`dart
await PPIntl.instance.setLanguage('it');
final greeting = PPIntl.textSync(PPIntlKey.hello);
\`\`\`

## Riferimento completo

Consulta la guida in inglese per tutte le chiavi, gli esempi e le note sulle prestazioni.

[README.md](README.md)

## License

MIT

