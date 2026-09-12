# PPIntl

حزمة Flutter خفيفة للترجمة الدولية، تتضمن ترجمات جاهزة لـ 18 لغة.

## التثبيت

أضف الحزمة إلى ملف `pubspec.yaml` ثم شغّل:

\`\`\`yaml
dependencies:
  pp_intl: ^1.1.1
\`\`\`

\`\`\`bash
flutter pub get
\`\`\`

## إعداد اللغة

استخدم رموز اللغات المدعومة عند استدعاء `setLanguage` أو `text` أو `textSync`. لا تتأثر الرموز بحالة الأحرف.

`ar`, `de`, `en`, `es`, `fil`, `fr`, `id`, `it`, `ja`, `ko`, `pl`, `pt`, `ru`, `th`, `tr`, `vi`, `zh_hans`, `zh_hant`

\`\`\`dart
import 'package:pp_intl/pp_intl.dart';

await PPIntl.instance.setLanguage('ar');
\`\`\`

## الاستخدام

استخدم الواجهة غير المتزامنة عند تحميل لغة لأول مرة.

\`\`\`dart
final greeting = await PPIntl.text(
  PPIntlKey.helloName,
  params: {'value': 'Taylor'},
);
\`\`\`

استخدم الواجهة المتزامنة بعد تحميل اللغة.

\`\`\`dart
await PPIntl.instance.setLanguage('ar');
final greeting = PPIntl.textSync(PPIntlKey.hello);
\`\`\`

## المرجع الكامل

للاطلاع على جميع المفاتيح والأمثلة وملاحظات الأداء، راجع الدليل الإنجليزي.

[README.md](README.md)

## License

MIT

