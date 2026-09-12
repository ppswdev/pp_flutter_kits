# PPIntl

แพ็กเกจ Flutter สำหรับการรองรับหลายภาษาขนาดเล็ก พร้อมคำแปลในตัวสำหรับ 18 ภาษา

## การติดตั้ง

เพิ่มแพ็กเกจลงใน `pubspec.yaml` แล้วรัน:

\`\`\`yaml
dependencies:
  pp_intl: ^1.1.1
\`\`\`

\`\`\`bash
flutter pub get
\`\`\`

## การตั้งค่าภาษา

ใช้รหัสภาษาที่รองรับกับ `setLanguage`, `text` หรือ `textSync` โดยไม่ต้องคำนึงถึงตัวพิมพ์เล็กและใหญ่

`ar`, `de`, `en`, `es`, `fil`, `fr`, `id`, `it`, `ja`, `ko`, `pl`, `pt`, `ru`, `th`, `tr`, `vi`, `zh_hans`, `zh_hant`

\`\`\`dart
import 'package:pp_intl/pp_intl.dart';

await PPIntl.instance.setLanguage('th');
\`\`\`

## การใช้งาน

ใช้ API แบบอะซิงโครนัสเมื่อโหลดภาษาเป็นครั้งแรก

\`\`\`dart
final greeting = await PPIntl.text(
  PPIntlKey.helloName,
  params: {'value': 'Taylor'},
);
\`\`\`

ใช้ API แบบซิงโครนัสหลังจากโหลดภาษาแล้วเท่านั้น

\`\`\`dart
await PPIntl.instance.setLanguage('th');
final greeting = PPIntl.textSync(PPIntlKey.hello);
\`\`\`

## ข้อมูลอ้างอิงฉบับเต็ม

ดูคู่มือภาษาอังกฤษสำหรับคีย์ทั้งหมด ตัวอย่าง และข้อควรพิจารณาด้านประสิทธิภาพ

[README.md](README.md)

## License

MIT

