# PPIntl

Un paquete ligero de internacionalización para Flutter con traducciones incluidas para 18 idiomas.

## Instalación

Añade el paquete a `pubspec.yaml` y ejecuta:

\`\`\`yaml
dependencies:
  pp_intl: ^1.1.1
\`\`\`

\`\`\`bash
flutter pub get
\`\`\`

## Configuración del idioma

Usa los códigos de idioma admitidos con `setLanguage`, `text` o `textSync`. No distinguen mayúsculas de minúsculas.

`ar`, `de`, `en`, `es`, `fil`, `fr`, `id`, `it`, `ja`, `ko`, `pl`, `pt`, `ru`, `th`, `tr`, `vi`, `zh_hans`, `zh_hant`

\`\`\`dart
import 'package:pp_intl/pp_intl.dart';

await PPIntl.instance.setLanguage('es');
\`\`\`

## Uso

Usa la API asíncrona cuando un idioma se cargue por primera vez.

\`\`\`dart
final greeting = await PPIntl.text(
  PPIntlKey.helloName,
  params: {'value': 'Taylor'},
);
\`\`\`

Usa la API síncrona solo después de cargar el idioma.

\`\`\`dart
await PPIntl.instance.setLanguage('es');
final greeting = PPIntl.textSync(PPIntlKey.hello);
\`\`\`

## Referencia completa

Consulta la guía en inglés para ver todas las claves, ejemplos y notas de rendimiento.

[README.md](README.md)

## License

MIT

