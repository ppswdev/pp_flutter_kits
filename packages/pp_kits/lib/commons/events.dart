/*
通用事件
*/

/// 网络连接状态事件
class NetworkConnectStatusEvent {
  final bool isConnected;
  final String message;

  NetworkConnectStatusEvent(this.isConnected, this.message);
}

/// 主题改变事件
class ThemeChangedEvent {
  final String message;

  ThemeChangedEvent(this.message);
}

/// VIP状态改变事件
class VipStatusChangedEvent {
  final String message;
  final bool isVip;

  VipStatusChangedEvent(this.message, this.isVip);
}

/// 产品信息改变事件
class ProductChangedEvent {
  final String message;

  ProductChangedEvent(this.message);
}

/// 语言改变事件
class LanguageChangedEvent {
  final String message;

  LanguageChangedEvent(this.message);
}
