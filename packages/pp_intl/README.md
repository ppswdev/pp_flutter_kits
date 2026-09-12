# PPIntl

A lightweight Flutter internationalization package with bundled translations for 18 languages. It provides reusable localization keys, parameterized text, on-demand asset loading, and cached synchronous access after initialization.

## Features

- 18 bundled languages
- Parameterized strings, for example `Hello {value}`
- On-demand language asset loading and caching
- Asynchronous and synchronous APIs
- English fallback for missing translations

## Installation

Add the package to `pubspec.yaml`:

```yaml
dependencies:
  pp_intl: ^1.1.1
```

Then run:

```bash
flutter pub get
```

## Import

```dart
import 'package:pp_intl/pp_intl.dart';
```

## Language Configuration

Use the language code in the following table with `setLanguage`, `text`, or `textSync`. Language codes are case-insensitive; the package normalizes them to lowercase internally.

| Language | Code |
| --- | --- |
| Arabic | `ar` |
| German | `de` |
| English (default) | `en` |
| Spanish | `es` |
| Filipino | `fil` |
| French | `fr` |
| Indonesian | `id` |
| Italian | `it` |
| Japanese | `ja` |
| Korean | `ko` |
| Polish | `pl` |
| Portuguese | `pt` |
| Russian | `ru` |
| Thai | `th` |
| Turkish | `tr` |
| Vietnamese | `vi` |
| Simplified Chinese | `zh_hans` |
| Traditional Chinese | `zh_hant` |

Initialize the default language during app startup:

```dart
await PPIntl.instance.setLanguage('zh_hans');
```

To switch languages later, call `setLanguage` again:

```dart
await PPIntl.instance.setLanguage('ja');
```

## Usage

### Asynchronous API

Use `PPIntl.text` when a language may not have been loaded yet. It loads the required asset automatically.

```dart
final hello = await PPIntl.text(PPIntlKey.hello);

final chineseHello = await PPIntl.text(
  PPIntlKey.hello,
  languageCode: 'zh_hans',
);

final greeting = await PPIntl.text(
  PPIntlKey.helloName,
  languageCode: 'en',
  params: {'value': 'John'},
);
```

### Synchronous API

Use `PPIntl.textSync` only after the requested language has been loaded—for example, after `setLanguage` or an earlier `PPIntl.text` call.

```dart
await PPIntl.instance.setLanguage('fr');

final greeting = PPIntl.textSync(PPIntlKey.hello);
final englishGreeting = PPIntl.textSync(
  PPIntlKey.hello,
  langCode: 'en',
);
```

### Parameters

Use the placeholder name defined by the translation value. The bundled parameterized strings use `{value}`.

```dart
final message = await PPIntl.text(
  PPIntlKey.helloName,
  params: {'value': 'Taylor'},
);
```

### Temporary Language Override

Pass `languageCode` to `text` or `langCode` to `textSync` to use another language without changing the default language.

```dart
final japaneseHello = await PPIntl.text(
  PPIntlKey.hello,
  languageCode: 'ja',
);
```

## Flutter App Example

Initialize PPIntl before rendering widgets that use synchronous localization:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PPIntl.instance.setLanguage('en');
  runApp(const MyApp());
}

class Greeting extends StatelessWidget {
  const Greeting({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(PPIntl.textSync(PPIntlKey.hello));
  }
}
```

## Available Keys

All keys are declared in [`PPIntlKey`](lib/src/pp_intl_key.dart). They cover common actions, dialogs, permissions, app review, agreements, in-app purchases, troubleshooting, settings, forms, and more. The English source values are in [`en.json`](assets/languages/en.json).

## Performance

- A language file is loaded only on first use.
- Loaded language data remains cached for subsequent lookups.
- Prefer `textSync` in rendering code after you initialize or preload the language.
- Use `text` for first loads and temporary language overrides.

## Troubleshooting

### `Unknown` is returned

The requested key was not found in the loaded language or in the English fallback. Confirm that the key exists in `PPIntlKey` and all language JSON files.

### A language cannot be loaded

Confirm that the language code is supported and that the corresponding JSON asset is declared by this package. Use the codes listed in [Language Configuration](#language-configuration).

### `textSync` does not return the expected translation

Load the language first with `await PPIntl.instance.setLanguage(code)` or with `await PPIntl.text(..., languageCode: code)`.

## Localized Documentation

Localized guides are available in the package root:

| Language | Guide |
| --- | --- |
| Arabic | [README_ar.md](README_ar.md) |
| German | [README_de.md](README_de.md) |
| Spanish | [README_es.md](README_es.md) |
| Filipino | [README_fil.md](README_fil.md) |
| French | [README_fr.md](README_fr.md) |
| Indonesian | [README_id.md](README_id.md) |
| Italian | [README_it.md](README_it.md) |
| Japanese | [README_ja.md](README_ja.md) |
| Korean | [README_ko.md](README_ko.md) |
| Polish | [README_pl.md](README_pl.md) |
| Portuguese | [README_pt.md](README_pt.md) |
| Russian | [README_ru.md](README_ru.md) |
| Thai | [README_th.md](README_th.md) |
| Turkish | [README_tr.md](README_tr.md) |
| Vietnamese | [README_vi.md](README_vi.md) |
| Traditional Chinese | [README_zh_hant.md](README_zh_hant.md) |

## License

MIT
