# PPIntl

18 dil için yerleşik çeviriler sunan hafif bir Flutter uluslararasılaştırma paketidir.

## Kurulum

Paketi `pubspec.yaml` dosyasına ekleyin, ardından çalıştırın:

\`\`\`yaml
dependencies:
  pp_intl: ^1.1.1
\`\`\`

\`\`\`bash
flutter pub get
\`\`\`

## Dil Yapılandırması

Desteklenen dil kodlarını `setLanguage`, `text` veya `textSync` ile kullanın. Büyük/küçük harf fark etmez.

`ar`, `de`, `en`, `es`, `fil`, `fr`, `id`, `it`, `ja`, `ko`, `pl`, `pt`, `ru`, `th`, `tr`, `vi`, `zh_hans`, `zh_hant`

\`\`\`dart
import 'package:pp_intl/pp_intl.dart';

await PPIntl.instance.setLanguage('tr');
\`\`\`

## Kullanım

Bir dili ilk kez yüklerken eşzamansız API’yi kullanın.

\`\`\`dart
final greeting = await PPIntl.text(
  PPIntlKey.helloName,
  params: {'value': 'Taylor'},
);
\`\`\`

Eşzamanlı API’yi yalnızca dil yüklendikten sonra kullanın.

\`\`\`dart
await PPIntl.instance.setLanguage('tr');
final greeting = PPIntl.textSync(PPIntlKey.hello);
\`\`\`

## Tam Başvuru

Tüm anahtarlar, örnekler ve performans notları için İngilizce kılavuza bakın.

[README.md](README.md)

## License

MIT

