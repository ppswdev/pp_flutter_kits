# PPIntl

Gói quốc tế hóa Flutter gọn nhẹ với bản dịch tích hợp cho 18 ngôn ngữ.

## Cài đặt

Thêm gói vào `pubspec.yaml`, sau đó chạy:

\`\`\`yaml
dependencies:
  pp_intl: ^1.1.1
\`\`\`

\`\`\`bash
flutter pub get
\`\`\`

## Cấu hình ngôn ngữ

Sử dụng mã ngôn ngữ được hỗ trợ với `setLanguage`, `text` hoặc `textSync`. Mã không phân biệt chữ hoa chữ thường.

`ar`, `de`, `en`, `es`, `fil`, `fr`, `id`, `it`, `ja`, `ko`, `pl`, `pt`, `ru`, `th`, `tr`, `vi`, `zh_hans`, `zh_hant`

\`\`\`dart
import 'package:pp_intl/pp_intl.dart';

await PPIntl.instance.setLanguage('vi');
\`\`\`

## Cách sử dụng

Sử dụng API bất đồng bộ khi tải ngôn ngữ lần đầu.

\`\`\`dart
final greeting = await PPIntl.text(
  PPIntlKey.helloName,
  params: {'value': 'Taylor'},
);
\`\`\`

Chỉ sử dụng API đồng bộ sau khi ngôn ngữ đã được tải.

\`\`\`dart
await PPIntl.instance.setLanguage('vi');
final greeting = PPIntl.textSync(PPIntlKey.hello);
\`\`\`

## Tài liệu đầy đủ

Xem hướng dẫn tiếng Anh để biết tất cả khóa, ví dụ và lưu ý về hiệu năng.

[README.md](README.md)

## License

MIT

