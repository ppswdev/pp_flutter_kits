# PPIntl

18개 언어 번역을 포함하는 가벼운 Flutter 국제화 패키지입니다.

## 설치

`pubspec.yaml`에 패키지를 추가한 뒤 다음을 실행하세요.

\`\`\`yaml
dependencies:
  pp_intl: ^1.1.1
\`\`\`

\`\`\`bash
flutter pub get
\`\`\`

## 언어 설정

`setLanguage`, `text`, `textSync`에 지원되는 언어 코드를 사용하세요. 언어 코드는 대소문자를 구분하지 않습니다.

`ar`, `de`, `en`, `es`, `fil`, `fr`, `id`, `it`, `ja`, `ko`, `pl`, `pt`, `ru`, `th`, `tr`, `vi`, `zh_hans`, `zh_hant`

\`\`\`dart
import 'package:pp_intl/pp_intl.dart';

await PPIntl.instance.setLanguage('ko');
\`\`\`

## 사용 방법

언어를 처음 불러올 때는 비동기 API를 사용하세요.

\`\`\`dart
final greeting = await PPIntl.text(
  PPIntlKey.helloName,
  params: {'value': 'Taylor'},
);
\`\`\`

동기 API는 언어를 불러온 후에만 사용하세요.

\`\`\`dart
await PPIntl.instance.setLanguage('ko');
final greeting = PPIntl.textSync(PPIntlKey.hello);
\`\`\`

## 전체 참조

모든 키, 예제 및 성능 참고 사항은 영어 가이드를 확인하세요.

[README.md](README.md)

## License

MIT

