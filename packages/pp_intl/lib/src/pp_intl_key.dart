/// Localization keys enum
enum PPIntlKey {
  // --- 基础问候 ---
  /// Hello | 你好
  hello,
  /// Welcome | 欢迎
  welcome,
  /// Goodbye | 再见
  goodbye,
  /// Thank you | 谢谢
  thankYou,
  /// Sorry | 对不起
  sorry,
  /// Hello {value} | 你好 {value}
  helloName,
  /// Welcome {value} | 欢迎 {value}
  welcomeName,

  // --- 通用按钮 ---
  /// Yes | 是
  yes,
  /// No | 否
  no,
  /// OK | 好的
  ok,
  /// Confirm | 确定
  confirm,
  /// Cancel | 取消
  cancel,
  /// Done | 完成
  done,
  /// Finish | 完成
  finish,
  /// Back | 返回
  back,
  /// Close | 关闭
  close,
  /// Continue | 继续
  continueText,
  /// Next | 下一步
  nextStep,
  /// Skip | 跳过
  skip,
  /// Options | 选项
  options,
  /// Decline | 拒绝
  refuse,
  /// Submit | 提交
  submit,
  /// Send | 发送
  send,
  /// Reply | 回复
  reply,
  /// Reset | 重置
  reset,
  /// Restore | 恢复
  restore,
  /// Details | 详情
  details,
  /// More | 更多
  more,
  /// All | 全部
  all,
  /// Preview | 预览
  preview,
  /// Download | 下载
  download,
  /// Upload | 上传
  upload,
  /// Install | 安装
  install,
  /// Backup | 备份
  backup,
  /// Follow System | 跟随系统
  followSystem,

  // --- 数据操作 ---
  /// Add | 添加
  add,
  /// Save | 保存
  save,
  /// Edit | 编辑
  edit,
  /// Delete | 删除
  delete,
  /// Update | 更新
  update,
  /// Remove | 移除
  remove,
  /// Clear | 清除
  clear,
  /// Search | 搜索
  search,
  /// Reload | 重新加载
  reload,

  // --- 操作结果 ---
  /// Success | 成功
  success,
  /// Something went wrong | 操作失败
  failed,
  /// Saved successfully | 保存成功
  savedSuccessfully,
  /// Deleted successfully | 删除成功
  deletedSuccessfully,
  /// Added successfully | 添加成功
  addedSuccessfully,
  /// Updated successfully | 更新成功
  updatedSuccessfully,

  // --- 应用评分 ---
  /// Rate | 评分
  appReviewRateTheApp,
  /// Rate on the App Store | 在 App Store 评分
  appReviewAppstoreRating,
  /// Later | 稍后
  appReviewLater,
  /// Yes, I like it | 是的，我喜欢
  appReviewYes,
  /// We are committed to providing the best user experience. If you enjoy using this  | 我们致力于提供最佳用户体验。如果您喜欢这款应用，请给我们五星好评😘😘😘
  appReviewText,
  /// Thank you for your support. We will keep improving the app! | 感谢您的支持，我们会努力让应用变得更好！
  appReviewText2,

  // --- 协议与隐私 ---
  /// Privacy Policy | 隐私政策
  agreementPrivacyPolicy,
  /// Privacy | 隐私
  agreementPrivacyAttr,
  /// End User License Agreement | 最终用户许可协议
  agreementEula,
  /// Terms | 条款
  agreementEulaAttr,
  /// Subscription Agreement | 订阅协议
  agreementSubsciption,
  /// Subscription | 订阅
  agreementSubsciptionAttr,
  /// I have read and agree to | 我已阅读并同意
  agreementAgree,
  /// [n] and [m] | [n] 和 [m]
  agreementText,
  /// Please read and agree to the terms before continuing. | 请先阅读并同意条款再继续。
  agreementUnagreeAlert,

  // --- 确认弹窗 ---
  /// Confirm Deletion | 确认删除
  deleteConfirmTitle,
  /// Are you sure you want to delete this item? | 确定要删除此项目吗？
  deleteConfirmMessage,
  /// Are you sure you want to exit? | 确定要退出吗？
  exitConfirmTitle,
  /// Press again to exit | 再按一次退出
  exitPressAgainToExit,
  /// Go back and try again | 返回重试
  backToRetry,

  // --- 媒体操作 ---
  /// Choose Photo | 选择照片
  pickImage,
  /// Photo Library | 照片库
  albums,
  /// Select Source | 选择来源
  fileSource,
  /// Files | 文件
  fileSourceDocument,
  /// Crop Image | 裁剪图片
  cropperImage,
  /// Camera access failed. Please check your camera permissions in Settings. | 相机访问失败。请在设置中检查您的相机权限。
  cameraTakeFailed,

  // --- 复制粘贴 ---
  /// Copy to Clipboard | 复制到剪贴板
  copyToClipboard,
  /// Copied | 已复制
  copied,
  /// Copied to clipboard | 已复制到剪贴板
  copiedToClipboard,

  // --- 网络错误 ---
  /// Network unavailable | 网络不可用
  networkNotAvailable,
  /// No network connection | 无网络连接
  noNetwork,
  /// Network Settings | 网络设置
  networkSettings,
  /// No internet connection detected. Please check your network settings and try agai | 未检测到互联网连接。请检查您的网络设置并重试。
  errorNetworkLost,
  /// Request timed out | 请求超时
  errorRequestTimeout,
  /// Request timed out. Please check your connection and try again. | 请求超时。请检查您的连接并重试。
  errorRequestTimeoutToRetry,

  // --- 加载状态 ---
  /// Please wait... | 请稍候...
  waiting,
  /// Loading... | 加载中...
  loading,
  /// Processing... | 处理中...
  processing,

  // --- 下拉刷新 ---
  /// Pull to refresh | 下拉刷新
  refreshIdle,
  /// Refreshing... | 刷新中...
  refreshRefreshing,
  /// Loading... | 加载中...
  refreshLoading,
  /// Release to refresh | 释放刷新
  refreshPulling,
  /// Pull up to load more | 上拉加载更多
  refreshPullup,
  /// All data loaded | 数据已加载
  refreshLoadCompleted,
  /// No more data | 已加载全部数据
  refreshNoMoreData,

  // --- 空状态 ---
  /// No data available | 暂无数据
  noData,
  /// No favorites yet | 暂无收藏
  noFavorites,
  /// No results found | 未找到相关内容
  noSearchResult,
  /// Invalid input | 输入无效
  invalidValue,
  /// Not implemented yet | 尚未实现
  notYetClear,

  // --- 设置菜单 ---
  /// Settings | 设置
  settings,
  /// Profile | 个人资料
  profile,
  /// About | 关于
  about,
  /// Help | 帮助
  help,
  /// Favorites | 收藏
  favorites,
  /// Share | 分享
  share,
  /// Feedback | 反馈
  feedback,
  /// Tell us what you think... | 告诉我们您的想法...
  feedbackPlaceHolder,
  /// Language | 语言
  language,
  /// Solutions | 解决方案
  solution,
  /// Contact | 联系
  contact,
  /// Support | 支持
  support,

  // --- 提示与权限 ---
  /// Tips | 温馨提示
  tipsTitle,
  /// Reminder | 提醒
  tipsReminder,
  /// Attention | 注意
  tipsAttention,
  /// Warning | 警告
  tipsWarning,
  /// Info | 信息
  tipsInfo,
  /// Note | 备注
  tipsNote,
  /// Something went wrong | 出错了
  tipsExceptionError,
  /// Please try restarting the app. If the problem persists, try reinstalling. | 请尝试重启应用。如果问题仍然存在，请尝试重新安装。
  tipsRestartOrReinstall,
  /// You have {value} attempts left today. Continue? | 您今天还剩 {value} 次体验机会。继续吗？
  tipsUseLimits,
  /// According to Apple requirements, network permission is required for the app to f | 根据苹果系统要求，应用获取网络授权后才能正常运行。为了获得更好的使用体验，请授予本应用网络权限。
  tipsNetworkText,
  /// Permission denied | 权限被拒绝
  permissionDenied,
  /// Permission required to continue | 需要此权限才能继续
  permissionRequired,
  /// Open Settings | 打开设置
  openSettings,

  // --- 版本更新 ---
  /// New Version Available | 发现新版本
  upgradeTitle,
  /// What's New | 更新内容
  upgradeContent,
  /// 🌟 A new version is here! Better design and smoother experience. Try it now! | 🌟 新版本来了！界面更美观，体验更流畅。快来试试吧！
  upgradeText,
  /// Update Now | 立即更新
  upgradeNow,
  /// Later | 稍后
  upgradeLater,

  // --- 内购相关 ---
  /// Pro | 专业版
  iapPro,
  /// Upgrade to Pro | 升级专业版
  iapUpgradePro,
  /// Premium | 高级版
  iapPremium,
  /// Upgrade to Premium | 升级高级版
  iapUpgradePremium,
  /// Purchasing... | 购买中
  iapPurchaseing,
  /// Verifying... | 验证中
  iapVerifying,
  /// Restoring... | 恢复中
  iapRestoring,
  /// Purchase Failed | 购买失败啦！
  iapPurchaseFailedTitle,
  /// An error occurred during the purchase. Tap "Solutions" for details and fixes. | 购买过程中出现错误，点击"解决方案"查看详细信息和解决方法。
  iapPurchaseFailedMsg,
  /// Restore your premium access? | 准备恢复您的高级访问权限？
  iapRestoreConfirmTitle,
  /// If you have previously purchased premium features on another device or after rei | 如果您之前在其他设备上或重新安装后购买了高级功能，我们可以帮助您恢复访问权限。请确保您使用与原始购买相同的账户登录。
  iapRestoreConfirmMsg,
  /// Welcome back to Premium! | 欢迎回到高级版！
  iapRestoreSuccessTitle,
  /// Your premium access has been successfully restored. Enjoy all the exclusive bene | 您的高级功能已成功恢复。享受订阅的所有专属福利！
  iapRestoreSuccessMsg,
  /// Restore Failed | 恢复失败啦！
  iapRestoreFailedTitle,
  /// An error occurred during the restore. Tap "Solutions" for details and fixes. | 购买过程中出现错误，点击"解决方案"查看错误详细信息和解决方法。
  iapRestoreFailedMsg,
  /// Report an Issue | 报告问题
  iapReportTitle,
  /// Send to:\n {value} | 发送至：\n {value}
  iapReportCopied,
  /// Report Now | 直接报告
  iapReportSend,
  /// Full Access | 完全访问
  iapFullAccess,
  /// Get All Features | 获取所有权限
  iapGetAllPermissions,
  /// Unlock all premium features with lifetime access! | 解锁所有高级功能，享受终身使用权限！
  iapUnlockAllFeatures,
  /// Limited-Time Gift! | 超级幸运礼包！
  iapLimitedTimeGiftTitle,
  /// Unlock lifetime access for just {value} | 解锁终身使用权限（仅需{value}）
  iapLimitedTimeGiftText,
  /// Limited-Time Offer | 限时优惠
  iapLimitedTimeOffer,
  /// One-time payment, unlock all premium features! | 一次付费，解锁全部高级功能！
  iapLimitedTimeOfferText,
  /// Save {value}% | 立省{value}%
  iapSavedOff,
  /// Purchase Now | 立即购买
  iapPurchaseNow,
  /// Lifetime Access | 终身使用
  iapLifetimeAccess,
  /// View Standard Plans | 查看标准套餐
  iapShowNormalSubscriptions,
  /// Start Free Trial | 开始免费试用
  iapFreeTrialStart,
  /// Free Trial | 0元试用
  iapFreeTrialZero,
  /// Free Trial | 免费试用
  iapFreeTrail,
  /// Subscribe | 订阅
  iapSubscribe,
  /// Family Sharing | 家庭共享
  iapFamilyShare,
  /// How to set up Family Sharing? | 如何设置家庭共享？
  iapFamilyShareSetTitle,
  /// To set up Family Sharing, go to Settings > Apple ID > Family Sharing and follow  | 要设置家庭共享，请前往“设置”>“Apple ID”>“家庭共享”，然后按照说明操作。
  iapFamilyShareSetDesc,
  /// View All Plans | 查看所有计划
  iapProductAllPlans,
  /// Choose the plan that suits you | 选择您合适的计划
  iapProductSelectPlan,
  /// Best Value | 最优惠
  iapProductBestValue,
  /// Week | 周
  iapProductWeek,
  /// Month | 月
  iapProductMonth,
  /// Year | 年
  iapProductYear,
  /// Weekly Plan | 每周会员
  iapWeeklyVip,
  /// Monthly Plan | 每月会员
  iapMonthlyVip,
  /// Yearly Plan | 每年会员
  iapYearlyVip,
  /// No payment today | 现在无需付款
  iapNoPaymentNow,
  /// Cancel anytime | 随时取消
  iapCancelAnytime,
  /// Secured by Apple | 受Apple保护
  iapProtectByApple,
  /// Restore | 恢复
  iapRestore,
  /// Cancel Subscription | 取消订阅
  iapCancelSubscription,
  /// Most Popular | 用户首选
  iapUserPreferred,
  /// Best Choice | 最佳订阅
  iapBestSubscription,
  /// Subscriptions | 订阅量
  iapSubsciptions,
  /// Downloads | 下载量
  iapDownloads,
  /// Cancel anytime with ease | 轻松随时取消
  iapCancelAnytimeWithEase,
  /// Free today | 今天不收费
  iapTodayFree,
  /// Free Trial Info | 免费试用信息
  iapFTI,
  /// Today: Instant access | 今天：立即访问
  iapFTISubTitle1,
  /// Unlock all features and enjoy premium benefits | 解锁全部功能，享受高级特权
  iapFTISubText1,
  /// You can enjoy full access for the day or cancel anytime. | 您仍然可以享受一整天的服务或提前取消订阅。
  iapFTISubText2,
  /// You will be charged later, but you can cancel anytime. | 您稍后会被收费，但可以随时取消。
  iapFTISubText3,
  /// How to cancel? | 如何取消？
  iapHowCancel,
  /// To cancel, go to Settings > Apple ID > Subscriptions, select the app, then tap " | 要取消，请前往设置 > Apple ID > 订阅，点击应用，然后选择"取消订阅"并确认。
  iapCancelDesc,
  /// Money-back guarantee | 退款保证
  iapRefund,
  /// What you get | 您将获得什么？
  iapWhatDoYouGet,
  /// Trusted by users worldwide | 全球用户信赖
  iapTBUW,
  /// No payment during trial | 试用期间无需付费
  iapTBUW1,
  /// 200K+ downloads | 20万+下载量
  iapTBUW2,
  /// 4.5★ average rating | 平均4.5星评分
  iapTBUW3,
  /// Cancel anytime | 随时取消订阅！
  iapTBUW4,
  /// Secure payment | 安全加密支付
  iapTBUW5,
  /// Great value | 卓越价值
  iapTBUW6,
  /// Highly rated | 广受好评
  iapWP,
  /// Skip for now | 暂时跳过
  iapSkip,
  /// Remind me before trial ends | 试用期结束前提醒我
  iapRemindText,

  // --- 解决方案 ---
  /// Current error details | 当前错误信息
  solutionCurrentErrorInfo,
  /// In-app purchase requirements | 应用内购买受限条件
  solutionPurchaseConditions,
  /// Network connection | 网络连接
  solutionNetworkConnection,
  /// A stable network connection is required to complete the payment | 需要稳定的网络连接才能完成支付
  solutionNetworkConnectionDesc,
  /// App Store account | AppStore账号
  solutionAppStoreAccount,
  /// You must be signed in with a valid App Store account | 必须登录有效的AppStore账号
  solutionAppStoreAccountDesc,
  /// Payment method | 支付方式
  solutionPaymentMethod,
  /// Your account must have a valid payment method | 账号必须绑定有效的支付方式
  solutionPaymentMethodDesc,
  /// Solutions | 解决方案
  solutionSolutions,
  /// Check network connection | 检查网络连接
  solutionCheckNetwork,
  /// Make sure your device is connected to a stable WiFi or cellular network | 确保设备连接到稳定的WiFi或蜂窝网络
  solutionCheckNetworkDesc,
  /// Verify App Store login | 验证AppStore登录
  solutionVerifyAppStore,
  /// Go to Settings > App Store and make sure you're signed in | 打开设置 > AppStore，确认已登录有效账号
  solutionVerifyAppStoreDesc,
  /// Check payment method | 检查支付方式
  solutionCheckPayment,
  /// Make sure your payment method is valid and not expired | 在AppStore中确认支付方式有效且未过期
  solutionCheckPaymentDesc,
  /// Restart the app | 重启应用
  solutionRestartApp,
  /// Close the app completely and reopen it | 完全关闭应用后重新打开
  solutionRestartAppDesc,
  /// Update system | 更新系统
  solutionUpdateSystem,
  /// The minimum supported version is iOS 15.0, but we recommend updating to iOS 18.0 | 系统默认最低支持15.0版本，但我们建议更新系统到iOS 18.0或以上版本
  solutionUpdateSystemDesc,
  /// Try again | 尝试重试
  solutionRetry,
  /// Retrying may resolve most issues automatically | 尝试重试可以解决大部分问题，苹果会自动处理。
  solutionRetryDesc,
  /// Contact support | 联系支持
  solutionContactSupport,
  /// If the issue persists, please contact our support team\n{value} | 如果问题持续，请联系我们的技术支持团队\n{value}
  solutionContactSupportDesc,

  // --- 设置选项 ---
  /// Themes | 主题
  settingsThemes,
  /// Sound | 声音
  settingsSound,
  /// Haptic Feedback | 触觉反馈
  settingsHapticFeedback,
  /// Language | 语言
  settingsLanguage,
  /// App Icon | 应用图标
  settingsAppicon,
  /// Share with Friends | 分享给朋友
  settingsShare,
  /// Rate Us | 给出评价
  settingsAppreview,
  /// Feedback | 反馈
  settingsFeedback,
  /// Feature Request | 建议功能
  settingsRequirementRequest,
  /// If you have any new ideas or features you'd like to see, just let us know. We ma | 如果您有任何新想法或创意概念，或者有想要但我们应用中没有的功能，只需告诉我们您的需求！将来某个时候，我们会为您提供新功能。
  settingsRequirementRequestTip,
  /// If you have any questions or suggestions, feel free to contact us. We are always | 如果您有任何问题或建议，可以直接联系我们。我们会努力改进和优化应用的功能和体验。祝您生活愉快！
  settingsFeedbackTip1,
  /// Thank you for your feedback. We will handle it promptly! | 感谢您的反馈，我们会及时处理！
  settingsFeedbackTip2,
  /// Your feedback is very important to us. We will continue improving based on your  | 您的反馈对我们非常重要，我们会根据您的建议不断改进应用。
  settingsFeedbackTip3,
  /// Would you like to send your feedback via email? | 想要通过电子邮件转发您的反馈吗？
  settingsFeedbackTip4,
  /// FAQ | 常见问题
  settingsFaq,
  /// About | 关于
  settingsAbout,

  // --- 表单相关 ---
  /// Email | 邮箱
  formEmailTitle,
  /// Email cannot be empty | 邮箱不能为空
  formEmailEmpty,
  /// Invalid email format | 邮箱格式无效
  formEmailFormatError,
  /// Enter your email | 请输入您的邮箱
  formEmailPlaceholder,
  /// Title | 标题
  formTitleTitle,
  /// Title cannot be empty | 标题不能为空
  formTitleEmpty,
  /// Enter a title | 请输入标题
  formTitlePlaceholder,
  /// Feedback | 反馈
  formFeedbackTitle,
  /// Feedback cannot be empty | 反馈不能为空
  formFeedbackEmpty,
  /// Enter your feedback | 请输入您的反馈
  formFeedbackPlaceholder,
  /// Suggestion | 建议
  formSuggestTitle,
  /// Suggestion cannot be empty | 建议不能为空
  formSuggestEmpty,
  /// Enter your suggestion | 请输入您的建议
  formSuggestPlaceholder,
  /// Submitted successfully | 提交成功
  formSubmitSuccess,
  /// Submission failed | 提交失败
  formSubmitFailed,

  // --- 输入规则 ---
  /// Input rules: Must be a valid integer. The minimum value must be greater than or  | 输入规则：必须是有效的整数格式。最小值必须大于或等于 0，且小于最大值。最大值必须小于 {max} 且大于最小值。
  inputRoleNumber,
}
