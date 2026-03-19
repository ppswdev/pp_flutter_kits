# PPIntl

一个轻量级的 Flutter 国际化包，支持 18 种语言和参数化字符串。解决多项目频繁手动整理翻译的繁琐工作，提高开发交付效率。

## 功能特点

- 支持 18 种国际语言，经过AI转译，确保符合各个国家文化习惯，风格的语言文字描述
- 支持参数化字符串（例如："你好 {name}"）
- 按需加载语言文件
- 缓存机制提高性能
- 单例模式便于访问
- 不支持的语言默认回退到英语
- 提供同步和异步方法，满足不同使用场景

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

## 安装

在 `pubspec.yaml` 文件中添加依赖：

```yaml
dependencies:
  pp_intl: ^1.0.0
```

然后运行：

```bash
flutter pub get
```

## 使用方法

### 导入包

```dart
import 'package:pp_intl/pp_intl.dart';
```

### 基本使用

#### 异步方法（推荐用于首次加载）

```dart
// 获取本地化文本
String hello = await PPIntl.text(PPIntlKey.hello, 'en');
print(hello); // 输出: Hello

// 获取带参数的本地化文本
String helloJohn = await PPIntl.text(PPIntlKey.helloName, 'en', {'name': 'John'});
print(helloJohn); // 输出: Hello John
```

#### 同步方法（仅在缓存存在时使用）

```dart
// 注意：使用同步方法前，必须确保该语言已经被加载到缓存中
// 例如，通过之前的异步调用或设置默认语言

String hello = PPIntl.textSync(PPIntlKey.hello);
print(hello); // 输出: 你好
```

### 设置默认语言

```dart
// 设置默认语言（会异步加载该语言）
await PPIntl.instance.setLanguage('zh_Hans');
print('默认语言设置为中文');

// 现在可以使用同步方法获取本地化文本
String hello = PPIntl.textSync(PPIntlKey.hello);
print(hello); // 输出: 你好

// 仍然可以使用异步方法（会自动检查缓存）
String helloAsync = await PPIntl.text(PPIntlKey.hello);
print(helloAsync); // 输出: 你好
```

### 多语言切换

```dart
// 设置默认语言为中文
await PPIntl.instance.setLanguage('zh_Hans');
print(PPIntl.textSync(PPIntlKey.hello)); // 输出: 你好

// 临时使用英语
String helloEn = await PPIntl.text(PPIntlKey.hello, 'en');
print(helloEn); // 输出: Hello

// 切换默认语言为英语
await PPIntl.instance.setLanguage('en');
print(PPIntl.textSync(PPIntlKey.hello)); // 输出: Hello
```

### 错误处理

```dart
// 尝试获取不存在的语言
String helloUnknown = await PPIntl.text(PPIntlKey.hello, 'xx');
print(helloUnknown); // 输出: Unknown（回退到英语）

// 尝试获取不存在的键
String unknownKey = await PPIntl.text(PPIntlKey.values[999], 'en');
print(unknownKey); // 输出: Unknown
```

### 支持的键

目前支持以下键（按功能分类）：

#### 基础问候

| 键名          | 英文            | 中文         | 备注   |
| ------------- | --------------- | ------------ | ------ |
| `hello`       | Hello           | 你好         |        |
| `welcome`     | Welcome         | 欢迎         |        |
| `goodbye`     | Goodbye         | 再见         |        |
| `thankYou`    | Thank you       | 谢谢         |        |
| `sorry`       | Sorry           | 对不起       |        |
| `helloName`   | Hello {value}   | 你好 {value} | 带参数 |
| `welcomeName` | Welcome {value} | 欢迎 {value} | 带参数 |

#### 通用按钮

| 键名           | 英文          | 中文     |
| -------------- | ------------- | -------- |
| `yes`          | Yes           | 是       |
| `no`           | No            | 否       |
| `ok`           | OK            | 好的     |
| `confirm`      | Confirm       | 确定     |
| `cancel`       | Cancel        | 取消     |
| `done`         | Done          | 完成     |
| `finish`       | Finish        | 完成     |
| `back`         | Back          | 返回     |
| `close`        | Close         | 关闭     |
| `continue`     | Continue      | 继续     |
| `nextStep`     | Next          | 下一步   |
| `skip`         | Skip          | 跳过     |
| `options`      | Options       | 选项     |
| `refuse`       | Decline       | 拒绝     |
| `submit`       | Submit        | 提交     |
| `send`         | Send          | 发送     |
| `reply`        | Reply         | 回复     |
| `reset`        | Reset         | 重置     |
| `restore`      | Restore       | 恢复     |
| `details`      | Details       | 详情     |
| `more`         | More          | 更多     |
| `all`          | All           | 全部     |
| `preview`      | Preview       | 预览     |
| `download`     | Download      | 下载     |
| `upload`       | Upload        | 上传     |
| `install`      | Install       | 安装     |
| `backup`       | Backup        | 备份     |
| `followSystem` | Follow System | 跟随系统 |

#### 数据操作

| 键名     | 英文   | 中文     |
| -------- | ------ | -------- |
| `add`    | Add    | 添加     |
| `save`   | Save   | 保存     |
| `edit`   | Edit   | 编辑     |
| `delete` | Delete | 删除     |
| `update` | Update | 更新     |
| `remove` | Remove | 移除     |
| `clear`  | Clear  | 清除     |
| `search` | Search | 搜索     |
| `reload` | Reload | 重新加载 |

#### 操作结果

| 键名                  | 英文                 | 中文     |
| --------------------- | -------------------- | -------- |
| `success`             | Success              | 成功     |
| `failed`              | Something went wrong | 操作失败 |
| `savedSuccessfully`   | Saved successfully   | 保存成功 |
| `deletedSuccessfully` | Deleted successfully | 删除成功 |
| `addedSuccessfully`   | Added successfully   | 添加成功 |
| `updatedSuccessfully` | Updated successfully | 更新成功 |

#### 应用评分

| 键名                      | 英文                                                      | 中文                          |
| ------------------------- | --------------------------------------------------------- | ----------------------------- |
| `appReviewRateTheApp`     | Rate                                                      | 评分                          |
| `appReviewAppstoreRating` | Rate on the App Store                                     | 在 App Store 评分             |
| `appReviewLater`          | Later                                                     | 稍后                          |
| `appReviewYes`            | Yes, I like it                                            | 是的，我喜欢                  |
| `appReviewText`           | We are committed to providing the best user experience... | 我们致力于提供最佳用户体验... |
| `appReviewText2`          | Thank you for your support...                             | 感谢您的支持...               |

#### 协议与隐私

| 键名                       | 英文                                                  | 中文                       |
| -------------------------- | ----------------------------------------------------- | -------------------------- |
| `agreementPrivacyPolicy`   | Privacy Policy                                        | 隐私政策                   |
| `agreementPrivacyAttr`     | Privacy                                               | 隐私                       |
| `agreementEula`            | End User License Agreement                            | 最终用户许可协议           |
| `agreementEulaAttr`        | Terms                                                 | 条款                       |
| `agreementSubsciption`     | Subscription Agreement                                | 订阅协议                   |
| `agreementSubsciptionAttr` | Subscription                                          | 订阅                       |
| `agreementAgree`           | I have read and agree to                              | 我已阅读并同意             |
| `agreementText`            | [n] and [m]                                           | [n] 和 [m]                 |
| `agreementUnagreeAlert`    | Please read and agree to the terms before continuing. | 请先阅读并同意条款再继续。 |

#### 确认弹窗

| 键名                   | 英文                                       | 中文                 |
| ---------------------- | ------------------------------------------ | -------------------- |
| `deleteConfirmTitle`   | Confirm Deletion                           | 确认删除             |
| `deleteConfirmMessage` | Are you sure you want to delete this item? | 确定要删除此项目吗？ |
| `exitConfirmTitle`     | Are you sure you want to exit?             | 确定要退出吗？       |
| `exitPressAgainToExit` | Press again to exit                        | 再按一次退出         |
| `backToRetry`          | Go back and try again                      | 返回重试             |

#### 媒体操作

| 键名                 | 英文                    | 中文            |
| -------------------- | ----------------------- | --------------- |
| `pickImage`          | Choose Photo            | 选择照片        |
| `albums`             | Photo Library           | 照片库          |
| `fileSource`         | Select Source           | 选择来源        |
| `fileSourceDocument` | Files                   | 文件            |
| `cropperImage`       | Crop Image              | 裁剪图片        |
| `cameraTakeFailed`   | Camera access failed... | 相机访问失败... |

#### 复制粘贴

| 键名                | 英文                | 中文           |
| ------------------- | ------------------- | -------------- |
| `copyToClipboard`   | Copy to Clipboard   | 复制到剪贴板   |
| `copied`            | Copied              | 已复制         |
| `copiedToClipboard` | Copied to clipboard | 已复制到剪贴板 |

#### 网络错误

| 键名                         | 英文                               | 中文                  |
| ---------------------------- | ---------------------------------- | --------------------- |
| `networkNotAvailable`        | Network unavailable                | 网络不可用            |
| `noNetwork`                  | No network connection              | 无网络连接            |
| `networkSettings`            | Network Settings                   | 网络设置              |
| `errorNetworkLost`           | No internet connection detected... | 未检测到互联网连接... |
| `errorRequestTimeout`        | Request timed out                  | 请求超时              |
| `errorRequestTimeoutToRetry` | Request timed out. Please check... | 请求超时。请检查...   |

#### 加载状态

| 键名         | 英文           | 中文      |
| ------------ | -------------- | --------- |
| `waiting`    | Please wait... | 请稍候... |
| `loading`    | Loading...     | 加载中... |
| `processing` | Processing...  | 处理中... |

#### 下拉刷新

| 键名                   | 英文                 | 中文           |
| ---------------------- | -------------------- | -------------- |
| `refreshIdle`          | Pull to refresh      | 下拉刷新       |
| `refreshRefreshing`    | Refreshing...        | 刷新中...      |
| `refreshLoading`       | Loading...           | 加载中...      |
| `refreshPulling`       | Release to refresh   | 释放刷新       |
| `refreshPullup`        | Pull up to load more | 上拉加载更多   |
| `refreshLoadCompleted` | All data loaded      | 数据已加载     |
| `refreshNoMoreData`    | No more data         | 已加载全部数据 |

#### 空状态

| 键名             | 英文                | 中文           |
| ---------------- | ------------------- | -------------- |
| `noData`         | No data available   | 暂无数据       |
| `noFavorites`    | No favorites yet    | 暂无收藏       |
| `noSearchResult` | No results found    | 未找到相关内容 |
| `invalidValue`   | Invalid input       | 输入无效       |
| `notYetClear`    | Not implemented yet | 尚未实现       |

#### 设置菜单

| 键名                  | 英文                      | 中文                |
| --------------------- | ------------------------- | ------------------- |
| `settings`            | Settings                  | 设置                |
| `profile`             | Profile                   | 个人资料            |
| `about`               | About                     | 关于                |
| `help`                | Help                      | 帮助                |
| `favorites`           | Favorites                 | 收藏                |
| `share`               | Share                     | 分享                |
| `feedback`            | Feedback                  | 反馈                |
| `feedbackPlaceHolder` | Tell us what you think... | 告诉我们您的想法... |
| `language`            | Language                  | 语言                |
| `solution`            | Solutions                 | 解决方案            |
| `contact`             | Contact                   | 联系                |
| `support`             | Support                   | 支持                |

#### 提示与权限

| 键名                     | 英文                                            | 中文                                    |
| ------------------------ | ----------------------------------------------- | --------------------------------------- |
| `tipsTitle`              | Tips                                            | 温馨提示                                |
| `tipsReminder`           | Reminder                                        | 提醒                                    |
| `tipsAttention`          | Attention                                       | 注意                                    |
| `tipsWarning`            | Warning                                         | 警告                                    |
| `tipsInfo`               | Info                                            | 信息                                    |
| `tipsNote`               | Note                                            | 备注                                    |
| `tipsExceptionError`     | Something went wrong                            | 出错了                                  |
| `tipsRestartOrReinstall` | Please try restarting the app...                | 请尝试重启应用...                       |
| `tipsUseLimits`          | You have {value} attempts left today. Continue? | 您今天还剩 {value} 次体验机会。继续吗？ |
| `tipsNetworkText`        | According to Apple requirements...              | 根据苹果系统要求...                     |
| `permissionDenied`       | Permission denied                               | 权限被拒绝                              |
| `permissionRequired`     | Permission required to continue                 | 需要此权限才能继续                      |
| `openSettings`           | Open Settings                                   | 打开设置                                |

#### 版本更新

| 键名             | 英文                      | 中文            |
| ---------------- | ------------------------- | --------------- |
| `upgradeTitle`   | New Version Available     | 发现新版本      |
| `upgradeContent` | What's New                | 更新内容        |
| `upgradeText`    | 🌟 A new version is here! | 🌟 新版本来了！ |
| `upgradeNow`     | Update Now                | 立即更新        |
| `upgradeLater`   | Later                     | 稍后            |

#### 内购相关

| 键名                         | 英文                                                     | 中文                                       |
| ---------------------------- | -------------------------------------------------------- | ------------------------------------------ |
| `iapPro`                     | Pro                                                      | 专业版                                     |
| `iapUpgradePro`              | Upgrade to Pro                                           | 升级专业版                                 |
| `iapPremium`                 | Premium                                                  | 高级版                                     |
| `iapUpgradePremium`          | Upgrade to Premium                                       | 升级高级版                                 |
| `iapPurchaseing`             | Purchasing...                                            | 购买中                                     |
| `iapVerifying`               | Verifying...                                             | 验证中                                     |
| `iapRestoring`               | Restoring...                                             | 恢复中                                     |
| `iapPurchaseFailedTitle`     | Purchase Failed                                          | 购买失败啦！                               |
| `iapPurchaseFailedMsg`       | An error occurred during the purchase...                 | 购买过程中出现错误...                      |
| `iapRestoreConfirmTitle`     | Restore your premium access?                             | 准备恢复您的高级访问权限？                 |
| `iapRestoreConfirmMsg`       | If you have previously purchased...                      | 如果您之前在其他设备上...                  |
| `iapRestoreSuccessTitle`     | Welcome back to Premium!                                 | 欢迎回到高级版！                           |
| `iapRestoreSuccessMsg`       | Your premium access has been successfully restored...    | 您的高级功能已成功恢复...                  |
| `iapRestoreFailedTitle`      | Restore Failed                                           | 恢复失败啦！                               |
| `iapRestoreFailedMsg`        | An error occurred during the restore...                  | 购买过程中出现错误...                      |
| `iapReportTitle`             | Report an Issue                                          | 报告问题                                   |
| `iapReportCopied`            | Send to:\n {value}                                       | 发送至：\n {value}                         |
| `iapReportSend`              | Report Now                                               | 直接报告                                   |
| `iapFullAccess`              | Full Access                                              | 完全访问                                   |
| `iapGetAllPermissions`       | Get All Features                                         | 获取所有权限                               |
| `iapUnlockAllFeatures`       | Unlock all premium features...                           | 解锁所有高级功能...                        |
| `iapLimitedTimeGiftTitle`    | Limited-Time Gift!                                       | 超级幸运礼包！                             |
| `iapLimitedTimeGiftText`     | Unlock lifetime access for just {value}                  | 解锁终身使用权限（仅需{value}）            |
| `iapLimitedTimeOffer`        | Limited-Time Offer                                       | 限时优惠                                   |
| `iapLimitedTimeOfferText`    | One-time payment, unlock all premium features!           | 一次付费，解锁全部高级功能！               |
| `iapSavedOff`                | Save {value}%                                            | 立省{value}%                               |
| `iapPurchaseNow`             | Purchase Now                                             | 立即购买                                   |
| `iapLifetimeAccess`          | Lifetime Access                                          | 终身使用                                   |
| `iapShowNormalSubscriptions` | View Standard Plans                                      | 查看标准套餐                               |
| `iapFreeTrialStart`          | Start Free Trial                                         | 开始免费试用                               |
| `iapFreeTrialZero`           | Free Trial                                               | 0元试用                                    |
| `iapFreeTrail`               | Free Trial                                               | 免费试用                                   |
| `iapSubscribe`               | Subscribe                                                | 订阅                                       |
| `iapFamilyShare`             | Family Sharing                                           | 家庭共享                                   |
| `iapFamilyShareSetTitle`     | How to set up Family Sharing?                            | 如何设置家庭共享？                         |
| `iapFamilyShareSetDesc`      | To set up Family Sharing...                              | 要设置家庭共享...                          |
| `iapProductAllPlans`         | View All Plans                                           | 查看所有计划                               |
| `iapProductSelectPlan`       | Choose the plan that suits you                           | 选择您合适的计划                           |
| `iapProductBestValue`        | Best Value                                               | 最优惠                                     |
| `iapProductWeek`             | Week                                                     | 周                                         |
| `iapProductMonth`            | Month                                                    | 月                                         |
| `iapProductYear`             | Year                                                     | 年                                         |
| `iapWeeklyVip`               | Weekly Plan                                              | 每周会员                                   |
| `iapMonthlyVip`              | Monthly Plan                                             | 每月会员                                   |
| `iapYearlyVip`               | Yearly Plan                                              | 每年会员                                   |
| `iapNoPaymentNow`            | No payment today                                         | 现在无需付款                               |
| `iapCancelAnytime`           | Cancel anytime                                           | 随时取消                                   |
| `iapProtectByApple`          | Secured by Apple                                         | 受Apple保护                                |
| `iapRestore`                 | Restore                                                  | 恢复                                       |
| `iapCancelSubscription`      | Cancel Subscription                                      | 取消订阅                                   |
| `iapUserPreferred`           | Most Popular                                             | 用户首选                                   |
| `iapBestSubscription`        | Best Choice                                              | 最佳订阅                                   |
| `iapSubsciptions`            | Subscriptions                                            | 订阅量                                     |
| `iapDownloads`               | Downloads                                                | 下载量                                     |
| `iapCancelAnytimeWithEase`   | Cancel anytime with ease                                 | 轻松随时取消                               |
| `iapTodayFree`               | Free today                                               | 今天不收费                                 |
| `iapFTI`                     | Free Trial Info                                          | 免费试用信息                               |
| `iapFTISubTitle1`            | Today: Instant access                                    | 今天：立即访问                             |
| `iapFTISubText1`             | Unlock all features and enjoy premium benefits           | 解锁全部功能，享受高级特权                 |
| `iapFTISubText2`             | You can enjoy full access for the day or cancel anytime. | 您仍然可以享受一整天的服务或提前取消订阅。 |
| `iapFTISubText3`             | You will be charged later, but you can cancel anytime.   | 您稍后会被收费，但可以随时取消。           |
| `iapHowCancel`               | How to cancel?                                           | 如何取消？                                 |
| `iapCancelDesc`              | To cancel, go to Settings > Apple ID > Subscriptions...  | 要取消，请前往设置 > Apple ID > 订阅...    |
| `iapRefund`                  | Money-back guarantee                                     | 退款保证                                   |
| `iapWhatDoYouGet`            | What you get                                             | 您将获得什么？                             |
| `iapTBUW`                    | Trusted by users worldwide                               | 全球用户信赖                               |
| `iapTBUW1`                   | No payment during trial                                  | 试用期间无需付费                           |
| `iapTBUW2`                   | 200K+ downloads                                          | 20万+下载量                                |
| `iapTBUW3`                   | 4.5★ average rating                                      | 平均4.5星评分                              |
| `iapTBUW4`                   | Cancel anytime                                           | 随时取消订阅！                             |
| `iapTBUW5`                   | Secure payment                                           | 安全加密支付                               |
| `iapTBUW6`                   | Great value                                              | 卓越价值                                   |
| `iapWP`                      | Highly rated                                             | 广受好评                                   |
| `iapSkip`                    | Skip for now                                             | 暂时跳过                                   |
| `iapRemindText`              | Remind me before trial ends                              | 试用期结束前提醒我                         |

#### 解决方案

| 键名                            | 英文                                                      | 中文                                    |
| ------------------------------- | --------------------------------------------------------- | --------------------------------------- |
| `solutionCurrentErrorInfo`      | Current error details                                     | 当前错误信息                            |
| `solutionPurchaseConditions`    | In-app purchase requirements                              | 应用内购买受限条件                      |
| `solutionNetworkConnection`     | Network connection                                        | 网络连接                                |
| `solutionNetworkConnectionDesc` | A stable network connection is required...                | 需要稳定的网络连接才能完成支付          |
| `solutionAppStoreAccount`       | App Store account                                         | AppStore账号                            |
| `solutionAppStoreAccountDesc`   | You must be signed in with a valid App Store account      | 必须登录有效的AppStore账号              |
| `solutionPaymentMethod`         | Payment method                                            | 支付方式                                |
| `solutionPaymentMethodDesc`     | Your account must have a valid payment method             | 账号必须绑定有效的支付方式              |
| `solutionSolutions`             | Solutions                                                 | 解决方案                                |
| `solutionCheckNetwork`          | Check network connection                                  | 检查网络连接                            |
| `solutionCheckNetworkDesc`      | Make sure your device is connected to a stable WiFi...    | 确保设备连接到稳定的WiFi或蜂窝网络      |
| `solutionVerifyAppStore`        | Verify App Store login                                    | 验证AppStore登录                        |
| `solutionVerifyAppStoreDesc`    | Go to Settings > App Store and make sure you're signed in | 打开设置 > AppStore，确认已登录有效账号 |
| `solutionCheckPayment`          | Check payment method                                      | 检查支付方式                            |
| `solutionCheckPaymentDesc`      | Make sure your payment method is valid and not expired    | 在AppStore中确认支付方式有效且未过期    |
| `solutionRestartApp`            | Restart the app                                           | 重启应用                                |
| `solutionRestartAppDesc`        | Close the app completely and reopen it                    | 完全关闭应用后重新打开                  |
| `solutionUpdateSystem`          | Update system                                             | 更新系统                                |
| `solutionUpdateSystemDesc`      | The minimum supported version is iOS 15.0...              | 系统默认最低支持15.0版本...             |
| `solutionRetry`                 | Try again                                                 | 尝试重试                                |
| `solutionRetryDesc`             | Retrying may resolve most issues automatically            | 尝试重试可以解决大部分问题...           |
| `solutionContactSupport`        | Contact support                                           | 联系支持                                |
| `solutionContactSupportDesc`    | If the issue persists, please contact our support team    | 如果问题持续，请联系我们的技术支持团队  |

#### 设置选项

| 键名                            | 英文                                            | 中文                             |
| ------------------------------- | ----------------------------------------------- | -------------------------------- |
| `settingsThemes`                | Themes                                          | 主题                             |
| `settingsSound`                 | Sound                                           | 声音                             |
| `settingsHapticFeedback`        | Haptic Feedback                                 | 触觉反馈                         |
| `settingsLanguage`              | Language                                        | 语言                             |
| `settingsAppicon`               | App Icon                                        | 应用图标                         |
| `settingsShare`                 | Share with Friends                              | 分享给朋友                       |
| `settingsAppreview`             | Rate Us                                         | 给出评价                         |
| `settingsFeedback`              | Feedback                                        | 反馈                             |
| `settingsRequirementRequest`    | Feature Request                                 | 建议功能                         |
| `settingsRequirementRequestTip` | If you have any new ideas...                    | 如果您有任何新想法或创意概念...  |
| `settingsFeedbackTip1`          | If you have any questions or suggestions...     | 如果您有任何问题或建议...        |
| `settingsFeedbackTip2`          | Thank you for your feedback...                  | 感谢您的反馈，我们会及时处理！   |
| `settingsFeedbackTip3`          | Your feedback is very important to us...        | 您的反馈对我们非常重要...        |
| `settingsFeedbackTip4`          | Would you like to send your feedback via email? | 想要通过电子邮件转发您的反馈吗？ |
| `settingsFaq`                   | FAQ                                             | 常见问题                         |
| `settingsAbout`                 | About                                           | 关于                             |

#### 表单相关

| 键名                      | 英文                       | 中文           |
| ------------------------- | -------------------------- | -------------- |
| `formEmailTitle`          | Email                      | 邮箱           |
| `formEmailEmpty`          | Email cannot be empty      | 邮箱不能为空   |
| `formEmailFormatError`    | Invalid email format       | 邮箱格式无效   |
| `formEmailPlaceholder`    | Enter your email           | 请输入您的邮箱 |
| `formTitleTitle`          | Title                      | 标题           |
| `formTitleEmpty`          | Title cannot be empty      | 标题不能为空   |
| `formTitlePlaceholder`    | Enter a title              | 请输入标题     |
| `formFeedbackTitle`       | Feedback                   | 反馈           |
| `formFeedbackEmpty`       | Feedback cannot be empty   | 反馈不能为空   |
| `formFeedbackPlaceholder` | Enter your feedback        | 请输入您的反馈 |
| `formSuggestTitle`        | Suggestion                 | 建议           |
| `formSuggestEmpty`        | Suggestion cannot be empty | 建议不能为空   |
| `formSuggestPlaceholder`  | Enter your suggestion      | 请输入您的建议 |
| `formSubmitSuccess`       | Submitted successfully     | 提交成功       |
| `formSubmitFailed`        | Submission failed          | 提交失败       |

#### 输入规则

| 键名              | 英文                                    | 中文                              | 备注   |
| ----------------- | --------------------------------------- | --------------------------------- | ------ |
| `inputRoleNumber` | Input rules: Must be a valid integer... | 输入规则：必须是有效的整数格式... | 带参数 |

## 高级用法

### 混合使用同步和异步方法

```dart
// 1. 应用启动时初始化默认语言
await PPIntl.instance.setLanguage('zh_Hans');

// 2. 在UI中使用同步方法（不需要await，响应更快）
Widget build(BuildContext context) {
  return Text(PPIntl.textSync(PPIntlKey.hello));
}

// 3. 在需要临时使用其他语言时使用异步方法
Future<void> showGreeting(String languageCode) async {
  String greeting = await PPIntl.text(PPIntlKey.hello, languageCode);
  print('$languageCode: $greeting');
}
```

### 批量加载多语言

```dart
Future<void> preloadLanguages() async {
  List<String> languages = ['en', 'zh_Hans', 'ja', 'ko'];
  for (String lang in languages) {
    await PPIntl.text(PPIntlKey.hello, lang);
    print('预加载 $lang 完成');
  }
}
```

## 性能考虑

- **按需加载**：语言文件仅在首次使用时加载，减少初始启动时间
- **缓存机制**：加载的语言会被缓存，后续访问速度快
- **同步方法**：在缓存存在时使用同步方法，避免不必要的异步操作
- **单例模式**：使用单例模式管理语言数据，避免重复实例化

## 最佳实践

1. **应用启动时初始化**：在应用启动时设置默认语言，确保后续可以使用同步方法
2. **预加载常用语言**：对于多语言应用，可在空闲时预加载常用语言
3. **错误处理**：对可能不存在的语言或键进行适当的错误处理
4. **使用同步方法**：在 UI 渲染中使用同步方法，提高响应速度
5. **使用异步方法**：在首次加载或切换语言时使用异步方法

## 故障排除

### 常见问题

1. **"Unknown" 输出**
   - 原因：语言文件未找到或加载失败
   - 解决：检查语言代码是否正确，确保 JSON 文件存在且格式正确

2. **资源加载失败**
   - 原因：assets 配置不正确或路径错误
   - 解决：确保 pubspec.yaml 中正确配置了 assets 路径，文件路径大小写与代码中一致

3. **同步方法返回 "Unknown"**
   - 原因：该语言尚未加载到缓存中
   - 解决：先使用异步方法加载语言，或设置为默认语言

## 许可证

MIT
