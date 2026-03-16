# PPIntl

一个轻量级的 Flutter 国际化包，支持 18 种语言和参数化字符串。

## 功能特点

- 支持 18 种国际语言
- 支持参数化字符串（例如："你好 {name}"）
- 按需加载语言文件
- 缓存机制提高性能
- 单例模式便于访问
- 不支持的语言默认回退到英语

## 支持的语言

- 阿拉伯语 (ar)
- 德语 (de)
- 英语 (en) - 默认
- 西班牙语 (es)
- 菲律宾语 (fil)
- 法语 (fr)
- 印尼语 (id)
- 意大利语 (it)
- 日语 (ja)
- 韩语 (ko)
- 波兰语 (pl)
- 葡萄牙语 (pt)
- 俄语 (ru)
- 泰语 (th)
- 土耳其语 (tr)
- 越南语 (vi)
- 简体中文 (zh_Hans)
- 繁体中文 (zh_Hant)

## 使用方法

### 基本使用

```dart
import 'package:pp_intl/pp_intl.dart';

// 获取本地化文本
String hello = await PPIntl.text(PPIntlKey.hello, 'en');
print(hello); // 输出: Hello

// 获取带参数的本地化文本
String helloJohn = await PPIntl.text(PPIntlKey.helloName, 'en', {'name': 'John'});
print(helloJohn); // 输出: Hello John
```

### 设置默认语言

```dart
// 设置默认语言（会异步加载该语言）
await PPIntl.instance.setLanguage('zh_Hans');

// 获取本地化文本
String hello = await PPIntl.text(PPIntlKey.hello);
print(hello); // 输出: 你好
```

### 支持的键

目前支持以下键：

- hello
- welcome
- goodbye
- thankYou
- sorry
- yes
- no
- ok
- cancel
- save
- delete
- edit
- add
- search
- settings
- profile
- help
- about
- language
- helloName (带参数)
- welcomeName (带参数)

## 添加新语言

要添加新语言：

1. 在 `assets/languages/` 目录中创建一个新的 JSON 文件，文件名使用语言代码（例如：`fr.json`）
2. 在 JSON 文件中添加所有键的翻译
3. 在 `pubspec.yaml` 中更新 assets 声明
4. 使用 `await PPIntl.instance.setLanguage('fr')` 或 `await PPIntl.text(PPIntlKey.hello, 'fr')` 加载该语言

## 添加新键

要添加新键：

1. 在 `lib/src/pp_intl_key.dart` 文件的 `PPIntlKey` 枚举中添加键
2. 在所有语言 JSON 文件中添加新键的翻译

## 性能考虑

- 语言文件按需加载，因此只有您实际使用的语言会被加载到内存中
- 翻译在首次加载后会被缓存，因此后续访问速度很快
- 该包使用单例模式避免不必要的实例化

## 许可证

MIT
