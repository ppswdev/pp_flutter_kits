private var ppInAppPurchaseLoggingEnabled = false

/// Updates the plugin-wide iOS logging state from Flutter's `showLog` option.
func setPPInAppPurchaseLoggingEnabled(_ isEnabled: Bool) {
    ppInAppPurchaseLoggingEnabled = isEnabled
}

/// StoreKit2Manager-wide logger. Keeping the switch and prefix here makes
/// purchase logs easy to control and filter without changing purchase behavior.
func ppInAppPurchaseLog(
    _ items: Any...,
    separator: String = " ",
    terminator: String = "\n"
) {
    guard ppInAppPurchaseLoggingEnabled else { return }
    let message = items.map { String(describing: $0) }.joined(separator: separator)
    Swift.print(
        "[pp_inapp_purchase][IOS] \(message)",
        terminator: terminator
    )
}
