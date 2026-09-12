# PPIntl

Um pacote Flutter leve de internacionalização com traduções incluídas para 18 idiomas.

## Instalação

Adicione o pacote ao `pubspec.yaml` e execute:

\`\`\`yaml
dependencies:
  pp_intl: ^1.1.1
\`\`\`

\`\`\`bash
flutter pub get
\`\`\`

## Configuração de idioma

Use os códigos de idioma suportados com `setLanguage`, `text` ou `textSync`. Os códigos não diferenciam maiúsculas de minúsculas.

`ar`, `de`, `en`, `es`, `fil`, `fr`, `id`, `it`, `ja`, `ko`, `pl`, `pt`, `ru`, `th`, `tr`, `vi`, `zh_hans`, `zh_hant`

\`\`\`dart
import 'package:pp_intl/pp_intl.dart';

await PPIntl.instance.setLanguage('pt');
\`\`\`

## Utilização

Use a API assíncrona quando um idioma for carregado pela primeira vez.

\`\`\`dart
final greeting = await PPIntl.text(
  PPIntlKey.helloName,
  params: {'value': 'Taylor'},
);
\`\`\`

Use a API síncrona apenas depois de carregar o idioma.

\`\`\`dart
await PPIntl.instance.setLanguage('pt');
final greeting = PPIntl.textSync(PPIntlKey.hello);
\`\`\`

## Referência completa

Consulte o guia em inglês para ver todas as chaves, exemplos e notas de desempenho.

[README.md](README.md)

## License

MIT

