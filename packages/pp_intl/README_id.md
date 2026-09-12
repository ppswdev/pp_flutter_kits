# PPIntl

Paket internasionalisasi Flutter yang ringan dengan terjemahan bawaan untuk 18 bahasa.

## Instalasi

Tambahkan paket ke `pubspec.yaml`, lalu jalankan:

\`\`\`yaml
dependencies:
  pp_intl: ^1.1.1
\`\`\`

\`\`\`bash
flutter pub get
\`\`\`

## Konfigurasi Bahasa

Gunakan kode bahasa yang didukung dengan `setLanguage`, `text`, atau `textSync`. Huruf besar dan kecil tidak dibedakan.

`ar`, `de`, `en`, `es`, `fil`, `fr`, `id`, `it`, `ja`, `ko`, `pl`, `pt`, `ru`, `th`, `tr`, `vi`, `zh_hans`, `zh_hant`

\`\`\`dart
import 'package:pp_intl/pp_intl.dart';

await PPIntl.instance.setLanguage('id');
\`\`\`

## Penggunaan

Gunakan API asinkron saat bahasa dimuat pertama kali.

\`\`\`dart
final greeting = await PPIntl.text(
  PPIntlKey.helloName,
  params: {'value': 'Taylor'},
);
\`\`\`

Gunakan API sinkron hanya setelah bahasa dimuat.

\`\`\`dart
await PPIntl.instance.setLanguage('id');
final greeting = PPIntl.textSync(PPIntlKey.hello);
\`\`\`

## Referensi Lengkap

Lihat panduan bahasa Inggris untuk semua kunci, contoh, dan catatan performa.

[README.md](README.md)

## License

MIT

