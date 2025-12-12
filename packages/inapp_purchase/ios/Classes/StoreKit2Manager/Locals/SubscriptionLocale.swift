//
//  SubscriptionLocale.swift
//  StoreKit2Manager
//
//  Created by xiaopin on 2025/12/6.
//

import Foundation
import StoreKit

/// 订阅产品国际化工具类
public struct SubscriptionLocale {
    
    /// 将 StoreKit 的周期单位转换为标准单位
    /// - Parameter period: 订阅周期
    /// - Returns: 标准单位字符串：day, week, month, year
    public static func getUnit(from period: Product.SubscriptionPeriod?) -> String {
        guard let period = period else { return "day" }
        
        let unit = period.unit
        let numberOfUnits = period.value
        
        switch unit {
        case .day:
            if numberOfUnits >= 365 {
                return "year"
            } else if numberOfUnits >= 30 {
                return "month"
            } else if numberOfUnits >= 7 {
                return "week"
            }
            return "day"
            
        case .week:
            if numberOfUnits >= 52 {
                return "year"
            } else if numberOfUnits >= 4 {
                return "month"
            }
            return "week"
            
        case .month:
            if numberOfUnits >= 12 {
                return "year"
            }
            return "month"
            
        case .year:
            return "year"
            
        @unknown default:
            if numberOfUnits >= 365 {
                return "year"
            } else if numberOfUnits >= 30 {
                return "month"
            } else if numberOfUnits >= 7 {
                return "week"
            }
            return "day"
        }
    }
    
    /// 获取本地化的单位文本
    /// - Parameters:
    ///   - languageCode: 语言代码
    ///   - numberOfPeriods: 周期数量
    ///   - unit: 单位（day, week, month, year）
    /// - Returns: 本地化的单位文本
    private static func getLocalizedUnit(languageCode: String, numberOfPeriods: Int, unit: String) -> String {
        switch languageCode {
        case "ar":
            switch unit {
            case "day": return numberOfPeriods == 1 ? "يوم" : "أيام"
            case "week": return numberOfPeriods == 1 ? "أسبوع" : "أسابيع"
            case "month": return numberOfPeriods == 1 ? "شهر" : "أشهر"
            case "year": return numberOfPeriods == 1 ? "سنة" : "سنوات"
            default: return numberOfPeriods == 1 ? "يوم" : "أيام"
            }
        case "de":
            switch unit {
            case "day": return "Täg"
            case "week": return "Wochen"
            case "month": return "Monat"
            case "year": return "Jahr"
            default: return "Täg"
            }
        case "en":
            switch unit {
            case "day": return numberOfPeriods == 1 ? "day" : "days"
            case "week": return numberOfPeriods == 1 ? "week" : "weeks"
            case "month": return numberOfPeriods == 1 ? "month" : "months"
            case "year": return numberOfPeriods == 1 ? "year" : "years"
            default: return numberOfPeriods == 1 ? "day" : "days"
            }
        case "es":
            switch unit {
            case "day": return numberOfPeriods == 1 ? "día" : "días"
            case "week": return numberOfPeriods == 1 ? "semana" : "semanas"
            case "month": return numberOfPeriods == 1 ? "mes" : "meses"
            case "year": return numberOfPeriods == 1 ? "año" : "años"
            default: return numberOfPeriods == 1 ? "día" : "días"
            }
        case "fil":
            switch unit {
            case "day": return "araw"
            case "week": return "linggo"
            case "month": return "buwan"
            case "year": return "taon"
            default: return "araw"
            }
        case "fr":
            switch unit {
            case "day": return numberOfPeriods == 1 ? "jour" : "jours"
            case "week": return numberOfPeriods == 1 ? "semaine" : "semaines"
            case "month": return numberOfPeriods == 1 ? "mois" : "mois"
            case "year": return numberOfPeriods == 1 ? "an" : "ans"
            default: return numberOfPeriods == 1 ? "jour" : "jours"
            }
        case "id":
            switch unit {
            case "day": return "hari"
            case "week": return "minggu"
            case "month": return "bulan"
            case "year": return "tahun"
            default: return "hari"
            }
        case "it":
            switch unit {
            case "day": return numberOfPeriods == 1 ? "giorno" : "giorni"
            case "week": return numberOfPeriods == 1 ? "settimana" : "settimane"
            case "month": return numberOfPeriods == 1 ? "mese" : "mesi"
            case "year": return numberOfPeriods == 1 ? "anno" : "anni"
            default: return numberOfPeriods == 1 ? "giorno" : "giorni"
            }
        case "ja":
            switch unit {
            case "day": return "日間"
            case "week": return "週間"
            case "month": return "ヶ月"
            case "year": return "年間"
            default: return "日間"
            }
        case "ko":
            switch unit {
            case "day": return "일"
            case "week": return "주"
            case "month": return "개월"
            case "year": return "년"
            default: return "일"
            }
        case "pl":
            switch unit {
            case "day": return numberOfPeriods == 1 ? "dzień" : "dni"
            case "week": return numberOfPeriods == 1 ? "tydzień" : "tygodni"
            case "month": return numberOfPeriods == 1 ? "miesiąc" : "miesięcy"
            case "year": return numberOfPeriods == 1 ? "rok" : "lat"
            default: return numberOfPeriods == 1 ? "dzień" : "dni"
            }
        case "pt":
            switch unit {
            case "day": return numberOfPeriods == 1 ? "dia" : "dias"
            case "week": return numberOfPeriods == 1 ? "semana" : "semanas"
            case "month": return numberOfPeriods == 1 ? "mês" : "meses"
            case "year": return numberOfPeriods == 1 ? "ano" : "anos"
            default: return numberOfPeriods == 1 ? "dia" : "dias"
            }
        case "ru":
            switch unit {
            case "day": return numberOfPeriods == 1 ? "день" : "дней"
            case "week": return numberOfPeriods == 1 ? "неделя" : "недель"
            case "month": return numberOfPeriods == 1 ? "месяц" : "месяцев"
            case "year": return numberOfPeriods == 1 ? "год" : "лет"
            default: return numberOfPeriods == 1 ? "день" : "дней"
            }
        case "th":
            switch unit {
            case "day": return "วัน"
            case "week": return "สัปดาห์"
            case "month": return "เดือน"
            case "year": return "ปี"
            default: return "วัน"
            }
        case "tr":
            switch unit {
            case "day": return "gün"
            case "week": return "hafta"
            case "month": return "ay"
            case "year": return "yıl"
            default: return "gün"
            }
        case "uk":
            switch unit {
            case "day": return numberOfPeriods == 1 ? "день" : "днів"
            case "week": return numberOfPeriods == 1 ? "тиждень" : "тижнів"
            case "month": return numberOfPeriods == 1 ? "місяць" : "місяців"
            case "year": return numberOfPeriods == 1 ? "рік" : "років"
            default: return numberOfPeriods == 1 ? "день" : "днів"
            }
        case "vi":
            switch unit {
            case "day": return "ngày"
            case "week": return "tuần"
            case "month": return "tháng"
            case "year": return "năm"
            default: return "ngày"
            }
        case "zh_Hans":
            switch unit {
            case "day": return "天"
            case "week": return "周"
            case "month": return "月"
            case "year": return "年"
            default: return "天"
            }
        case "zh_Hant":
            switch unit {
            case "day": return "天"
            case "week": return "周"
            case "month": return "月"
            case "year": return "年"
            default: return "天"
            }
        default:
            switch unit {
            case "day": return numberOfPeriods == 1 ? "day" : "days"
            case "week": return numberOfPeriods == 1 ? "week" : "weeks"
            case "month": return numberOfPeriods == 1 ? "month" : "months"
            case "year": return numberOfPeriods == 1 ? "year" : "years"
            default: return numberOfPeriods == 1 ? "day" : "days"
            }
        }
    }

    /// 从 Product 的 displayPrice 中提取货币符号
    /// 通过从 displayPrice 中移除价格数字部分来获取货币符号
    /// - Parameter product: Product 对象
    /// - Returns: 货币符号字符串
    public static func getCurrencySymbol(from product: Product) -> String {
        let displayPrice = product.displayPrice
        let priceDecimal = product.price
        let priceDouble = NSDecimalNumber(decimal: priceDecimal).doubleValue
        
        // 生成多种可能的价格格式字符串
        var pricePatterns: [String] = []
        
        // 1. 标准格式 "9.99"
        pricePatterns.append(String(format: "%.2f", priceDouble))
        
        // 2. 整数格式（如果价格是整数）
        if priceDouble.truncatingRemainder(dividingBy: 1) == 0 {
            pricePatterns.append(String(format: "%.0f", priceDouble))
        }
        
        // 3. 一位小数格式 "9.9"（如果最后一位是0）
        let priceString = String(format: "%.2f", priceDouble)
        if priceString.hasSuffix("0") {
            pricePatterns.append(String(format: "%.1f", priceDouble))
        }
        
        // 4. 本地化格式（可能包含千位分隔符，如 "1,234.56" 或 "1.234,56"）
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        if let localizedPrice = formatter.string(from: NSNumber(value: priceDouble)) {
            pricePatterns.append(localizedPrice)
        }
        
        // 5. 本地化整数格式
        if priceDouble.truncatingRemainder(dividingBy: 1) == 0 {
            formatter.maximumFractionDigits = 0
            if let localizedPrice = formatter.string(from: NSNumber(value: priceDouble)) {
                pricePatterns.append(localizedPrice)
            }
        }
        
        // 从 displayPrice 中移除所有可能的价格格式
        var cleanedPrice = displayPrice
        for pattern in pricePatterns {
            // 移除价格（处理前后可能有空格的情况）
            cleanedPrice = cleanedPrice.replacingOccurrences(of: " \(pattern) ", with: " ")
            cleanedPrice = cleanedPrice.replacingOccurrences(of: "\(pattern) ", with: " ")
            cleanedPrice = cleanedPrice.replacingOccurrences(of: " \(pattern)", with: " ")
            cleanedPrice = cleanedPrice.replacingOccurrences(of: pattern, with: "")
        }
        
        // 进一步清理：移除所有数字、小数点、逗号
        cleanedPrice = cleanedPrice.replacingOccurrences(of: #"\d"#, with: "", options: .regularExpression)
        cleanedPrice = cleanedPrice.replacingOccurrences(of: #"[.,]"#, with: "", options: .regularExpression)
        
        // 清理多余的空格
        cleanedPrice = cleanedPrice.trimmingCharacters(in: .whitespaces)
        cleanedPrice = cleanedPrice.replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
        cleanedPrice = cleanedPrice.trimmingCharacters(in: .whitespaces)
        
        // 如果提取成功且不为空，返回货币符号
        if !cleanedPrice.isEmpty {
            return cleanedPrice
        }
        
        // 后备方案：使用 Locale.current.currencySymbol
        return Locale.current.currencySymbol ?? "$"
    }
    // MARK: - 按钮文案
    
    /// 获取订阅按钮文案
    /// - Parameters:
    ///   - type: 按钮类型
    ///   - languageCode: 语言代码
    /// - Returns: 本地化的按钮文案
    public static func subscriptionButtonText(type: SubscriptionButtonType, languageCode: String) -> String {
        switch languageCode {
        case "ar":
            switch type {
            case .standard: return "اشترك"
            case .freeTrial: return "جرّب مجانًا"
            case .payUpFront: return "ادفع الآن"
            case .payAsYouGo: return "ادفع حسب الاستخدام"
            case .lifetime: return "اشتر مدى الحياة"
            }
        case "de":
            switch type {
            case .standard: return "Abonnieren"
            case .freeTrial: return "Kostenlos testen"
            case .payUpFront: return "Jetzt bezahlen"
            case .payAsYouGo: return "Bezahlen nach Nutzung"
            case .lifetime: return "Lebenslang kaufen"
            }
        case "en":
            switch type {
            case .standard: return "Subscribe"
            case .freeTrial: return "Start Free Trial"
            case .payUpFront: return "Prepay Now"
            case .payAsYouGo: return "Pay As You Go"
            case .lifetime: return "Buy Lifetime"
            }
        case "es":
            switch type {
            case .standard: return "Suscribirse"
            case .freeTrial: return "Prueba gratis"
            case .payUpFront: return "Pagar ahora"
            case .payAsYouGo: return "Pagar por uso"
            case .lifetime: return "Comprar de por vida"
            }
        case "fil":
            switch type {
            case .standard: return "Mag-subscribe"
            case .freeTrial: return "Subukan nang libre"
            case .payUpFront: return "Magbayad ngayon"
            case .payAsYouGo: return "Magbayad ayon sa paggamit"
            case .lifetime: return "Bilhin ang panghabang-buhay"
            }
        case "fr":
            switch type {
            case .standard: return "S'abonner"
            case .freeTrial: return "Essai gratuit"
            case .payUpFront: return "Payer maintenant"
            case .payAsYouGo: return "Payer à l'usage"
            case .lifetime: return "Acheter à vie"
            }
        case "id":
            switch type {
            case .standard: return "Berlangganan"
            case .freeTrial: return "Coba gratis"
            case .payUpFront: return "Bayar sekarang"
            case .payAsYouGo: return "Bayar sesuai pemakaian"
            case .lifetime: return "Beli seumur hidup"
            }
        case "it":
            switch type {
            case .standard: return "Abbonati"
            case .freeTrial: return "Prova gratuita"
            case .payUpFront: return "Paga ora"
            case .payAsYouGo: return "Paga a consumo"
            case .lifetime: return "Acquista a vita"
            }
        case "ja":
            switch type {
            case .standard: return "購読する"
            case .freeTrial: return "無料トライアル開始"
            case .payUpFront: return "今すぐ支払う"
            case .payAsYouGo: return "使った分だけ支払う"
            case .lifetime: return "生涯購入"
            }
        case "ko":
            switch type {
            case .standard: return "구독하기"
            case .freeTrial: return "무료 체험 시작"
            case .payUpFront: return "지금 결제"
            case .payAsYouGo: return "사용한 만큼 결제"
            case .lifetime: return "평생 구매"
            }
        case "pl":
            switch type {
            case .standard: return "Subskrybuj"
            case .freeTrial: return "Wypróbuj za darmo"
            case .payUpFront: return "Zapłać teraz"
            case .payAsYouGo: return "Płać zgodnie z użyciem"
            case .lifetime: return "Kup na całe życie"
            }
        case "pt":
            switch type {
            case .standard: return "Assinar"
            case .freeTrial: return "Teste grátis"
            case .payUpFront: return "Pagar agora"
            case .payAsYouGo: return "Pagar conforme o uso"
            case .lifetime: return "Comprar vitalício"
            }
        case "ru":
            switch type {
            case .standard: return "Подписаться"
            case .freeTrial: return "Попробовать бесплатно"
            case .payUpFront: return "Оплатить сейчас"
            case .payAsYouGo: return "Оплата по мере использования"
            case .lifetime: return "Купить навсегда"
            }
        case "th":
            switch type {
            case .standard: return "สมัครสมาชิก"
            case .freeTrial: return "ทดลองใช้ฟรี"
            case .payUpFront: return "ชำระตอนนี้"
            case .payAsYouGo: return "จ่ายตามการใช้งาน"
            case .lifetime: return "ซื้อตลอดชีพ"
            }
        case "tr":
            switch type {
            case .standard: return "Abone ol"
            case .freeTrial: return "Ücretsiz dene"
            case .payUpFront: return "Şimdi öde"
            case .payAsYouGo: return "Kullandıkça öde"
            case .lifetime: return "Yaşam boyu satın al"
            }
        case "uk":
            switch type {
            case .standard: return "Підписатися"
            case .freeTrial: return "Спробувати безкоштовно"
            case .payUpFront: return "Оплатити зараз"
            case .payAsYouGo: return "Оплата за мірою використання"
            case .lifetime: return "Купити назавжди"
            }
        case "vi":
            switch type {
            case .standard: return "Đăng ký"
            case .freeTrial: return "Dùng thử miễn phí"
            case .payUpFront: return "Thanh toán ngay"
            case .payAsYouGo: return "Trả theo nhu cầu"
            case .lifetime: return "Mua trọn đời"
            }
        case "zh_Hans":
            switch type {
            case .standard: return "订阅"
            case .freeTrial: return "开始免费试用"
            case .payUpFront: return "立即支付"
            case .payAsYouGo: return "按需付费"
            case .lifetime: return "购买终身"
            }
        case "zh_Hant":
            switch type {
            case .standard: return "訂閱"
            case .freeTrial: return "開始免費試用"
            case .payUpFront: return "立即支付"
            case .payAsYouGo: return "按需付費"
            case .lifetime: return "購買終身"
            }
        default:
            // 默认返回英语
            switch type {
            case .standard: return "Subscribe"
            case .freeTrial: return "Start Free Trial"
            case .payUpFront: return "Prepay Now"
            case .payAsYouGo: return "Pay As You Go"
            case .lifetime: return "Buy Lifetime"
            }
        }
    }
    
    // MARK: - 订阅标题
    
    /// 获取订阅标题
    /// - Parameters:
    ///   - periodType: 持续时间类型（week, month, year, lifetime）
    ///   - languageCode: 语言代码
    ///   - isShort: 是否使用简短版本
    /// - Returns: 本地化的标题
    public static func subscriptionTitle(periodType: SubscriptionPeriodType, languageCode: String, isShort: Bool = false) -> String {
        switch languageCode {
        case "ar":
            switch periodType {
            case .week: return isShort ? "أسبوعي" : "اشتراك أسبوعي"
            case .month: return isShort ? "شهري" : "اشتراك شهري"
            case .year: return isShort ? "سنوي" : "اشتراك سنوي"
            case .lifetime: return isShort ? "مدى الحياة" : "اشتراك مدى الحياة"
            }
        case "de":
            switch periodType {
            case .week: return isShort ? "Woche" : "Wöchentliches Abo"
            case .month: return isShort ? "Monat" : "Monatliches Abo"
            case .year: return isShort ? "Jahr" : "Jährliches Abo"
            case .lifetime: return isShort ? "Lebenslang" : "Lebenslanges Abo"
            }
        case "en":
            switch periodType {
            case .week: return isShort ? "Weekly" : "Weekly Subscription"
            case .month: return isShort ? "Monthly" : "Monthly Subscription"
            case .year: return isShort ? "Yearly" : "Annual Subscription"
            case .lifetime: return isShort ? "Lifetime" : "Lifetime Membership"
            }
        case "es":
            switch periodType {
            case .week: return isShort ? "Semanal" : "Suscripción semanal"
            case .month: return isShort ? "Mensual" : "Suscripción mensual"
            case .year: return isShort ? "Anual" : "Suscripción anual"
            case .lifetime: return isShort ? "De por vida" : "Suscripción de por vida"
            }
        case "fil":
            switch periodType {
            case .week: return isShort ? "Lingguhan" : "Lingguhang Subscription"
            case .month: return isShort ? "Buwanang" : "Buwanang Subscription"
            case .year: return isShort ? "Taunan" : "Taunang Subscription"
            case .lifetime: return isShort ? "Panghabang-buhay" : "Panghabang-buhay na Subscription"
            }
        case "fr":
            switch periodType {
            case .week: return isShort ? "Hebdo" : "Abonnement hebdomadaire"
            case .month: return isShort ? "Mensuel" : "Abonnement mensuel"
            case .year: return isShort ? "Annuel" : "Abonnement annuel"
            case .lifetime: return isShort ? "À vie" : "Abonnement à vie"
            }
        case "id":
            switch periodType {
            case .week: return isShort ? "Mingguan" : "Langganan mingguan"
            case .month: return isShort ? "Bulanan" : "Langganan bulanan"
            case .year: return isShort ? "Tahunan" : "Langganan tahunan"
            case .lifetime: return isShort ? "Seumur hidup" : "Langganan seumur hidup"
            }
        case "it":
            switch periodType {
            case .week: return isShort ? "Sett." : "Abbonamento settimanale"
            case .month: return isShort ? "Mese" : "Abbonamento mensile"
            case .year: return isShort ? "Anno" : "Abbonamento annuale"
            case .lifetime: return isShort ? "A vita" : "Abbonamento a vita"
            }
        case "ja":
            switch periodType {
            case .week: return isShort ? "週額" : "週額プラン"
            case .month: return isShort ? "月額" : "月額プラン"
            case .year: return isShort ? "年額" : "年額プラン"
            case .lifetime: return isShort ? "生涯" : "生涯プラン"
            }
        case "ko":
            switch periodType {
            case .week: return isShort ? "주간" : "주간 구독"
            case .month: return isShort ? "월간" : "월간 구독"
            case .year: return isShort ? "연간" : "연간 구독"
            case .lifetime: return isShort ? "평생" : "평생 회원권"
            }
        case "pl":
            switch periodType {
            case .week: return isShort ? "Tyg." : "Subskrypcja tygodniowa"
            case .month: return isShort ? "Mies." : "Subskrypcja miesięczna"
            case .year: return isShort ? "Rocznie" : "Subskrypcja roczna"
            case .lifetime: return isShort ? "Dożywotnia" : "Subskrypcja dożywotnia"
            }
        case "pt":
            switch periodType {
            case .week: return isShort ? "Semanal" : "Assinatura semanal"
            case .month: return isShort ? "Mensal" : "Assinatura mensal"
            case .year: return isShort ? "Anual" : "Assinatura anual"
            case .lifetime: return isShort ? "Vitalício" : "Assinatura vitalícia"
            }
        case "ru":
            switch periodType {
            case .week: return isShort ? "Неделя" : "Еженедельная подписка"
            case .month: return isShort ? "Месяц" : "Ежемесячная подписка"
            case .year: return isShort ? "Год" : "Годовая подписка"
            case .lifetime: return isShort ? "Навсегда" : "Пожизненная подписка"
            }
        case "th":
            switch periodType {
            case .week: return isShort ? "รายสัปดาห์" : "สมัครสมาชิกแบบรายสัปดาห์"
            case .month: return isShort ? "รายเดือน" : "สมัครสมาชิกแบบรายเดือน"
            case .year: return isShort ? "รายปี" : "สมัครสมาชิกแบบรายปี"
            case .lifetime: return isShort ? "ตลอดชีพ" : "สมาชิกตลอดชีพ"
            }
        case "tr":
            switch periodType {
            case .week: return isShort ? "Haftalık" : "Haftalık abonelik"
            case .month: return isShort ? "Aylık" : "Aylık abonelik"
            case .year: return isShort ? "Yıllık" : "Yıllık abonelik"
            case .lifetime: return isShort ? "Ömür boyu" : "Ömür boyu abonelik"
            }
        case "uk":
            switch periodType {
            case .week: return isShort ? "Тиж." : "Тижнева підписка"
            case .month: return isShort ? "Міс." : "Місячна підписка"
            case .year: return isShort ? "Рік" : "Річна підписка"
            case .lifetime: return isShort ? "Довічна" : "Довічна підписка"
            }
        case "vi":
            switch periodType {
            case .week: return isShort ? "Tuần" : "Gói thuê bao hàng tuần"
            case .month: return isShort ? "Tháng" : "Gói thuê bao hàng tháng"
            case .year: return isShort ? "Năm" : "Gói thuê bao hàng năm"
            case .lifetime: return isShort ? "Trọn đời" : "Gói trọn đời"
            }
        case "zh_Hans":
            switch periodType {
            case .week: return isShort ? "周会员" : "每周会员"
            case .month: return isShort ? "月会员" : "每月会员"
            case .year: return isShort ? "年会员" : "年度会员"
            case .lifetime: return isShort ? "终身会员" : "终身会员"
            }
        case "zh_Hant":
            switch periodType {
            case .week: return isShort ? "週會員" : "每週會員"
            case .month: return isShort ? "月會員" : "每月會員"
            case .year: return isShort ? "年會員" : "年度會員"
            case .lifetime: return isShort ? "終身會員" : "終身會員"
            }
        default:
            // 默认返回英语
            switch periodType {
            case .week: return isShort ? "Weekly" : "Weekly Subscription"
            case .month: return isShort ? "Monthly" : "Monthly Subscription"
            case .year: return isShort ? "Yearly" : "Annual Subscription"
            case .lifetime: return isShort ? "Lifetime" : "Lifetime Membership"
            }
        }
    }
    
    // MARK: - 订阅副标题

    /// 获取订阅类型描述词
    /// - Parameters:
    ///   - periodType: 持续时间类型
    ///   - languageCode: 语言代码
    /// - Returns: 描述词（如：灵活选择、性价比之选、最优惠）
    private static func defaultSubDescWord(periodType: SubscriptionPeriodType, languageCode: String) -> String {
        switch languageCode {
        case "ar":
            switch periodType {
            case .week: return "مرونة"
            case .month: return "قيمة ممتازة"
            case .year: return "الأكثر توفيراً"
            case .lifetime: return "اشتراك دائم بدون تجديد"
            }
        case "de":
            switch periodType {
            case .week: return "Flexibilität"
            case .month: return "Bester Wert"
            case .year: return "Meist gespart"
            case .lifetime: return "Einmalig zahlen, dauerhaft nutzen"
            }
        case "en":
            switch periodType {
            case .week: return "Flexible"
            case .month: return "Best Value"
            case .year: return "Most Popular"
            case .lifetime: return "Pay once, own forever"
            }
        case "es":
            switch periodType {
            case .week: return "Flexible"
            case .month: return "Mejor Valor"
            case .year: return "Más Popular"
            case .lifetime: return "Paga una vez, disfruta siempre"
            }
        case "fil":
            switch periodType {
            case .week: return "Nakakalag"
            case .month: return "Pinakamahusay na Halaga"
            case .year: return "Pinakasikat"
            case .lifetime: return "Isang beses lang, habambuhay na"
            }
        case "fr":
            switch periodType {
            case .week: return "Flexible"
            case .month: return "Meilleur Rapport"
            case .year: return "Plus Populaire"
            case .lifetime: return "Achetez une fois, profitez à vie"
            }
        case "id":
            switch periodType {
            case .week: return "Fleksibel"
            case .month: return "Nilai Terbaik"
            case .year: return "Paling Populer"
            case .lifetime: return "Bayar sekali, pakai selamanya"
            }
        case "it":
            switch periodType {
            case .week: return "Flessibile"
            case .month: return "Miglior Valore"
            case .year: return "Più Popolare"
            case .lifetime: return "Paga una volta, usa per sempre"
            }
        case "ja":
            switch periodType {
            case .week: return "柔軟性"
            case .month: return "お得"
            case .year: return "人気"
            case .lifetime: return "一度の支払いで永久利用"
            }
        case "ko":
            switch periodType {
            case .week: return "유연함"
            case .month: return "최고 가치"
            case .year: return "인기"
            case .lifetime: return "한 번 결제로 평생 이용"
            }
        case "pl":
            switch periodType {
            case .week: return "Elastyczność"
            case .month: return "Najlepsza Wartość"
            case .year: return "Najpopularniejsze"
            case .lifetime: return "Zapłać raz, korzystaj zawsze"
            }
        case "pt":
            switch periodType {
            case .week: return "Flexível"
            case .month: return "Melhor Valor"
            case .year: return "Mais Popular"
            case .lifetime: return "Pague uma vez, use para sempre"
            }
        case "ru":
            switch periodType {
            case .week: return "Гибкость"
            case .month: return "Лучшая Цена"
            case .year: return "Популярный"
            case .lifetime: return "Оплати один раз, используй всегда"
            }
        case "th":
            switch periodType {
            case .week: return "ยืดหยุ่น"
            case .month: return "คุ้มค่าที่สุด"
            case .year: return "ยอดนิยม"
            case .lifetime: return "จ่ายครั้งเดียว ใช้ได้ตลอดชีพ"
            }
        case "tr":
            switch periodType {
            case .week: return "Esnek"
            case .month: return "En İyi Değer"
            case .year: return "En Popüler"
            case .lifetime: return "Bir kez öde, sürekli kullan"
            }
        case "uk":
            switch periodType {
            case .week: return "Гнучкість"
            case .month: return "Найкраща Ціна"
            case .year: return "Популярний"
            case .lifetime: return "Сплати один раз, використовуй завжди"
            }
        case "vi":
            switch periodType {
            case .week: return "Linh hoạt"
            case .month: return "Giá trị tốt nhất"
            case .year: return "Phổ biến nhất"
            case .lifetime: return "Thanh toán một lần, sử dụng mãi mãi"
            }
        case "zh_Hans":
            switch periodType {
            case .week: return "灵活选择"
            case .month: return "性价比之选"
            case .year: return "最优惠"
            case .lifetime: return "一次购买，终身访问"
            }
        case "zh_Hant":
            switch periodType {
            case .week: return "靈活選擇"
            case .month: return "性價比之選"
            case .year: return "最優惠"
            case .lifetime: return "一次購買，終生訪問"
            }
        default:
            switch periodType {
            case .week: return "Flexible"
            case .month: return "Best Value"
            case .year: return "Most Popular"
            case .lifetime: return "Pay once, own forever"
            }
        }
    }
    
    /// 获取订阅副标题
    /// - Parameters:
    ///   - product: 产品对象
    ///   - periodType: 持续时间类型
    ///   - languageCode: 语言代码
    /// - Returns: 本地化的副标题
    public static func defaultSubtitle(product: Product, periodType: SubscriptionPeriodType, languageCode: String) -> String {
        let priceDouble = NSDecimalNumber(decimal: product.price).doubleValue
        let priceString = String(format: "%.2f", priceDouble)
        let currencySymbol = getCurrencySymbol(from: product)
        var productUnit = periodType.rawValue
        if let subscription = product.subscription {
            productUnit = getLocalizedUnit(languageCode: languageCode, numberOfPeriods: 1, unit: getUnit(from: subscription.subscriptionPeriod))
        }
        
        // 原价订阅描述：灵活选择、性价比之选、最优惠
        let description = defaultSubDescWord(periodType: periodType, languageCode: languageCode)
 
        if periodType == .lifetime {
            // 终身会员只返回描述
            return description
        } else if periodType == .week {
            return description + "," + buildDefaultSubtitle(languageCode: languageCode, price: priceString, currencySymbol: currencySymbol, productUnit: productUnit)
        } else if periodType == .month {
            return description + "," + buildMonthlySubtitle(languageCode: languageCode, price: priceString, currencySymbol: currencySymbol)
        } else if periodType == .year {
            return description + "," +  buildYearlySubtitle(languageCode: languageCode, price: priceString, currencySymbol: currencySymbol)
        }
        return buildDefaultSubtitle(languageCode: languageCode, price: priceString, currencySymbol: currencySymbol, productUnit: productUnit)
    }
    
    /// 获取介绍性优惠副标题
    /// - Parameters:
    ///   - product: 产品对象
    ///   - languageCode: 语言代码
    /// - Returns: 本地化的介绍性优惠副标题
    public static func introductoryOfferSubtitle(product: Product, languageCode: String) async -> String {
        guard let subscription = product.subscription,
              let introductoryOffer = subscription.introductoryOffer else {
            return ""
        }
        
        let priceDouble = NSDecimalNumber(decimal: product.price).doubleValue
        let priceString = String(format: "%.2f", priceDouble)
        let currencySymbol = getCurrencySymbol(from: product)

        //print("introductoryOfferSubtitle:priceString \(priceString) currencySymbol: \(currencySymbol)")
        
        // 获取产品单位
        let productUnit = getUnit(from: subscription.subscriptionPeriod)
        let localizedUnit = getLocalizedUnit(languageCode: languageCode, numberOfPeriods: 1, unit: productUnit)
        
        // 获取介绍性优惠价格
        let introPrice = introductoryOffer.price
        let introPriceDouble = NSDecimalNumber(decimal: introPrice).doubleValue
        let introPriceString = String(format: "%.2f", introPriceDouble)
        
        switch introductoryOffer.paymentMode {
        case .payAsYouGo:
            // 按需付费：显示折扣价格
            let numberOfPeriods = introductoryOffer.periodCount
            return buildPayAsYouGoText(
                languageCode: languageCode,
                introPrice: introPriceString,
                currencySymbol: currencySymbol,
                productUnit: localizedUnit,
                numberOfPeriods: numberOfPeriods
            )
            
        case .payUpFront:
            // 预付：显示节省金额和折扣价格
            return buildPayUpFrontText(
                languageCode: languageCode,
                introPrice: introPriceString,
                originalPrice: priceString,
                currencySymbol: currencySymbol,
                productUnit: localizedUnit
            )
            
        case .freeTrial:
            // 免费试用：显示试用期和后续价格
            let trialPeriod = introductoryOffer.period
            let numberOfPeriods = trialPeriod.value
            let trialUnit = getUnit(from: trialPeriod)
            let trialLocalizedUnit = getLocalizedUnit(languageCode: languageCode, numberOfPeriods: numberOfPeriods, unit: trialUnit)
            
            return buildFreeTrialText(
                languageCode: languageCode,
                numberOfPeriods: numberOfPeriods,
                trialPeriodUnit: trialLocalizedUnit,
                productUnit: localizedUnit,
                price: priceString,
                currencySymbol: currencySymbol
            )
            
        default:
            return ""
        }
    }
    
    /// 获取促销优惠副标题
    /// - Parameters:
    ///   - product: 产品对象
    ///   - languageCode: 语言代码
    /// - Returns: 本地化的促销优惠副标题
    public static func promotionalOfferSubtitle(product: Product, languageCode: String) async -> String {
        guard let subscription = product.subscription,
              let promotionalOffer = subscription.promotionalOffers.first else {
            return ""
        }
        
        let priceDouble = NSDecimalNumber(decimal: product.price).doubleValue
        let priceString = String(format: "%.2f", priceDouble)
        let currencySymbol = getCurrencySymbol(from: product)
        
        // 获取产品单位
        let productUnit = getUnit(from: subscription.subscriptionPeriod)
        let localizedUnit = getLocalizedUnit(languageCode: languageCode, numberOfPeriods: 1, unit: productUnit)
        
        // 获取促销优惠价格
        let discountPrice = promotionalOffer.price
        let discountPriceDouble = NSDecimalNumber(decimal: discountPrice).doubleValue
        let discountPriceString = String(format: "%.2f", discountPriceDouble)
        
        switch promotionalOffer.paymentMode {
        case .payAsYouGo:
            // 按需付费：显示折扣价格
            let numberOfPeriods = promotionalOffer.periodCount
            return buildPayAsYouGoText(
                languageCode: languageCode,
                introPrice: discountPriceString,
                currencySymbol: currencySymbol,
                productUnit: localizedUnit,
                numberOfPeriods: numberOfPeriods
            )
            
        case .payUpFront:
            // 预付：显示节省金额和折扣价格
            return buildPayUpFrontText(
                languageCode: languageCode,
                introPrice: discountPriceString,
                originalPrice: priceString,
                currencySymbol: currencySymbol,
                productUnit: localizedUnit
            )
            
        case .freeTrial:
            // 免费试用：显示试用期和后续价格
            let trialPeriod = promotionalOffer.period
            let numberOfPeriods = trialPeriod.value
            let trialUnit = getUnit(from: trialPeriod)
            let trialLocalizedUnit = getLocalizedUnit(languageCode: languageCode, numberOfPeriods: numberOfPeriods, unit: trialUnit)
            
            return buildFreeTrialText(
                languageCode: languageCode,
                numberOfPeriods: numberOfPeriods,
                trialPeriodUnit: trialLocalizedUnit,
                productUnit: localizedUnit,
                price: priceString,
                currencySymbol: currencySymbol
            )
            
        default:
            return ""
        }
    }
    
   
    
    // MARK: - 价格格式化辅助方法
    
    /// 构建默认价格显示
    /// - Parameters:
    ///   - languageCode: 语言代码
    ///   - price: 价格字符串
    ///   - currencySymbol: 货币符号
    ///   - productUnit: 产品单位（本地化）
    /// - Returns: 格式化的价格字符串
    private static func buildDefaultSubtitle(languageCode: String, price: String, currencySymbol: String, productUnit: String) -> String {
        switch languageCode {
        case "ar", "de", "en", "es", "fil", "fr", "id", "it", "ja", "ko", "pl", "pt", "ru", "th", "tr", "uk", "vi":
            return "\(currencySymbol)\(price)/\(productUnit)"
        case "zh_Hans":
            return "每\(productUnit)\(currencySymbol)\(price)元"
        case "zh_Hant":
            return "每\(productUnit)\(currencySymbol)\(price)"
        default:
            return "\(currencySymbol)\(price)/\(productUnit)"
        }
    }
    
    /// 构建月订阅价格显示 - 突出性价比
    /// - Parameters:
    ///   - languageCode: 语言代码
    ///   - price: 价格字符串
    ///   - currencySymbol: 货币符号
    /// - Returns: 格式化的价格字符串
    private static func buildMonthlySubtitle(languageCode: String, price: String, currencySymbol: String) -> String {
        let monthlyPrice = Double(price) ?? 0
        let weeklyPrice = monthlyPrice / 4.33
        let weeklyPriceString = String(format: "%.2f", weeklyPrice)
        
        switch languageCode {
        case "ar":
            return "\(currencySymbol)\(price)/شهر · ~\(currencySymbol)\(weeklyPriceString)/أسبوع"
        case "de":
            return "\(currencySymbol)\(price)/Monat · ~\(currencySymbol)\(weeklyPriceString)/Woche"
        case "en":
            return "\(currencySymbol)\(price)/month · ~\(currencySymbol)\(weeklyPriceString)/week"
        case "es":
            return "\(currencySymbol)\(price)/mes · ~\(currencySymbol)\(weeklyPriceString)/semana"
        case "fil":
            return "\(currencySymbol)\(price)/buwan · ~\(currencySymbol)\(weeklyPriceString)/linggo"
        case "fr":
            return "\(currencySymbol)\(price)/mois · ~\(currencySymbol)\(weeklyPriceString)/semaine"
        case "id":
            return "\(currencySymbol)\(price)/bulan · ~\(currencySymbol)\(weeklyPriceString)/minggu"
        case "it":
            return "\(currencySymbol)\(price)/mese · ~\(currencySymbol)\(weeklyPriceString)/settimana"
        case "ja":
            return "\(currencySymbol)\(price)/月 · 約\(currencySymbol)\(weeklyPriceString)/週"
        case "ko":
            return "\(currencySymbol)\(price)/월 · 약\(currencySymbol)\(weeklyPriceString)/주"
        case "pl":
            return "\(currencySymbol)\(price)/miesiąc · ~\(currencySymbol)\(weeklyPriceString)/tydzień"
        case "pt":
            return "\(currencySymbol)\(price)/mês · ~\(currencySymbol)\(weeklyPriceString)/semana"
        case "ru":
            return "\(currencySymbol)\(price)/мес · ~\(currencySymbol)\(weeklyPriceString)/нед"
        case "th":
            return "\(currencySymbol)\(price)/เดือน · ~\(currencySymbol)\(weeklyPriceString)/สัปดาห์"
        case "tr":
            return "\(currencySymbol)\(price)/ay · ~\(currencySymbol)\(weeklyPriceString)/hafta"
        case "uk":
            return "\(currencySymbol)\(price)/міс · ~\(currencySymbol)\(weeklyPriceString)/тиж"
        case "vi":
            return "\(currencySymbol)\(price)/tháng · ~\(currencySymbol)\(weeklyPriceString)/tuần"
        case "zh_Hans":
            return "每月\(currencySymbol)\(price)元 · 约\(currencySymbol)\(weeklyPriceString)元/周"
        case "zh_Hant":
            return "每月\(currencySymbol)\(price) · 約\(currencySymbol)\(weeklyPriceString)/周"
        default:
            return "\(currencySymbol)\(price)/month · ~\(currencySymbol)\(weeklyPriceString)/week"
        }
    }
    
    /// 构建年订阅价格显示 - 突出最大优惠
    /// - Parameters:
    ///   - languageCode: 语言代码
    ///   - price: 价格字符串
    ///   - currencySymbol: 货币符号
    /// - Returns: 格式化的价格字符串
    private static func buildYearlySubtitle(languageCode: String, price: String, currencySymbol: String) -> String {
        let yearlyPrice = Double(price) ?? 0
        let weeklyPrice = yearlyPrice / 52
        let weeklyPriceString = String(format: "%.2f", weeklyPrice)
        
        switch languageCode {
        case "ar":
            return "\(currencySymbol)\(price)/سنة · فقط \(currencySymbol)\(weeklyPriceString)/أسبوع"
        case "de":
            return "\(currencySymbol)\(price)/Jahr · nur \(currencySymbol)\(weeklyPriceString)/Woche"
        case "en":
            return "\(currencySymbol)\(price)/year · only \(currencySymbol)\(weeklyPriceString)/week"
        case "es":
            return "\(currencySymbol)\(price)/año · solo \(currencySymbol)\(weeklyPriceString)/semana"
        case "fil":
            return "\(currencySymbol)\(price)/taon · \(currencySymbol)\(weeklyPriceString)/linggo lang"
        case "fr":
            return "\(currencySymbol)\(price)/an · seulement \(currencySymbol)\(weeklyPriceString)/semaine"
        case "id":
            return "\(currencySymbol)\(price)/tahun · hanya \(currencySymbol)\(weeklyPriceString)/minggu"
        case "it":
            return "\(currencySymbol)\(price)/anno · solo \(currencySymbol)\(weeklyPriceString)/settimana"
        case "ja":
            return "\(currencySymbol)\(price)/年 · わずか\(currencySymbol)\(weeklyPriceString)/週"
        case "ko":
            return "\(currencySymbol)\(price)/년 · 단\(currencySymbol)\(weeklyPriceString)/주"
        case "pl":
            return "\(currencySymbol)\(price)/rok · tylko \(currencySymbol)\(weeklyPriceString)/tydzień"
        case "pt":
            return "\(currencySymbol)\(price)/ano · apenas \(currencySymbol)\(weeklyPriceString)/semana"
        case "ru":
            return "\(currencySymbol)\(price)/год · всего \(currencySymbol)\(weeklyPriceString)/нед"
        case "th":
            return "\(currencySymbol)\(price)/ปี · เพียง \(currencySymbol)\(weeklyPriceString)/สัปดาห์"
        case "tr":
            return "\(currencySymbol)\(price)/yıl · sadece \(currencySymbol)\(weeklyPriceString)/hafta"
        case "uk":
            return "\(currencySymbol)\(price)/рік · ~\(currencySymbol)\(weeklyPriceString)/тиж"
        case "vi":
            return "\(currencySymbol)\(price)/năm · chỉ \(currencySymbol)\(weeklyPriceString)/tuần"
        case "zh_Hans":
            return "每年\(currencySymbol)\(price)元 · 仅\(currencySymbol)\(weeklyPriceString)元/周"
        case "zh_Hant":
            return "每年\(currencySymbol)\(price) · 僅\(currencySymbol)\(weeklyPriceString)/周"
        default:
            return "\(currencySymbol)\(price)/year · only \(currencySymbol)\(weeklyPriceString)/week"
        }
    }
    
    // MARK: - 优惠相关副标题
    
    
    
    /// 构建按需付费文本
    /// - Parameters:
    ///   - languageCode: 语言代码
    ///   - introPrice: 优惠价格字符串
    ///   - currencySymbol: 货币符号
    ///   - productUnit: 产品单位（本地化）
    ///   - numberOfPeriods: 周期数量
    /// - Returns: 格式化的按需付费文本
    private static func buildPayAsYouGoText(languageCode: String, introPrice: String, currencySymbol: String, productUnit: String, numberOfPeriods: Int) -> String {
        switch languageCode {
        case "ar":
            if numberOfPeriods == 1 {
                return "عرض خاص: \(currencySymbol)\(introPrice)/\(productUnit) (الأسبوع الأول)"
            } else {
                return "عرض خاص: \(currencySymbol)\(introPrice)/\(productUnit) (الأسبوعين الأولين)"
            }
        case "de":
            if numberOfPeriods == 1 {
                return "Sonderangebot: \(currencySymbol)\(introPrice)/\(productUnit) (erste Woche)"
            } else {
                return "Sonderangebot: \(currencySymbol)\(introPrice)/\(productUnit) (erste \(numberOfPeriods) Wochen)"
            }
        case "en":
            if numberOfPeriods == 1 {
                return "Special offer: \(currencySymbol)\(introPrice)/\(productUnit) (first \(productUnit))"
            } else {
                return "Special offer: \(currencySymbol)\(introPrice)/\(productUnit) (first \(numberOfPeriods) \(productUnit)s)"
            }
        case "es":
            if numberOfPeriods == 1 {
                return "Oferta especial: \(currencySymbol)\(introPrice)/\(productUnit) (primer \(productUnit))"
            } else {
                return "Oferta especial: \(currencySymbol)\(introPrice)/\(productUnit) (primeros \(numberOfPeriods) \(productUnit)s)"
            }
        case "fil":
            if numberOfPeriods == 1 {
                return "Espesyal na alok: \(currencySymbol)\(introPrice)/\(productUnit) (unang \(productUnit))"
            } else {
                return "Espesyal na alok: \(currencySymbol)\(introPrice)/\(productUnit) (unang \(numberOfPeriods) \(productUnit)s)"
            }
        case "fr":
            if numberOfPeriods == 1 {
                return "Offre spéciale: \(currencySymbol)\(introPrice)/\(productUnit) (premier \(productUnit))"
            } else {
                return "Offre spéciale: \(currencySymbol)\(introPrice)/\(productUnit) (premiers \(numberOfPeriods) \(productUnit)s)"
            }
        case "id":
            if numberOfPeriods == 1 {
                return "Penawaran khusus: \(currencySymbol)\(introPrice)/\(productUnit) (\(productUnit) pertama)"
            } else {
                return "Penawaran khusus: \(currencySymbol)\(introPrice)/\(productUnit) (\(numberOfPeriods) \(productUnit) pertama)"
            }
        case "it":
            if numberOfPeriods == 1 {
                return "Offerta speciale: \(currencySymbol)\(introPrice)/\(productUnit) (primo \(productUnit))"
            } else {
                return "Offerta speciale: \(currencySymbol)\(introPrice)/\(productUnit) (primi \(numberOfPeriods) \(productUnit)s)"
            }
        case "ja":
            if numberOfPeriods == 1 {
                return "特別価格: \(currencySymbol)\(introPrice)/\(productUnit) (初回\(productUnit))"
            } else {
                return "特別価格: \(currencySymbol)\(introPrice)/\(productUnit) (初回\(numberOfPeriods)\(productUnit))"
            }
        case "ko":
            if numberOfPeriods == 1 {
                return "특별 할인: \(currencySymbol)\(introPrice)/\(productUnit) (첫 \(productUnit))"
            } else {
                return "특별 할인: \(currencySymbol)\(introPrice)/\(productUnit) (첫 \(numberOfPeriods)\(productUnit))"
            }
        case "pl":
            if numberOfPeriods == 1 {
                return "Oferta specjalna: \(currencySymbol)\(introPrice)/\(productUnit) (pierwszy \(productUnit))"
            } else {
                return "Oferta specjalna: \(currencySymbol)\(introPrice)/\(productUnit) (pierwsze \(numberOfPeriods) \(productUnit)s)"
            }
        case "pt":
            if numberOfPeriods == 1 {
                return "Oferta especial: \(currencySymbol)\(introPrice)/\(productUnit) (primeiro \(productUnit))"
            } else {
                return "Oferta especial: \(currencySymbol)\(introPrice)/\(productUnit) (primeiros \(numberOfPeriods) \(productUnit)s)"
            }
        case "ru":
            if numberOfPeriods == 1 {
                return "Специальное предложение: \(currencySymbol)\(introPrice)/\(productUnit) (первый \(productUnit))"
            } else {
                return "Специальное предложение: \(currencySymbol)\(introPrice)/\(productUnit) (первые \(numberOfPeriods) \(productUnit)s)"
            }
        case "th":
            if numberOfPeriods == 1 {
                return "ข้อเสนอพิเศษ: \(currencySymbol)\(introPrice)/\(productUnit) (\(productUnit)แรก)"
            } else {
                return "ข้อเสนอพิเศษ: \(currencySymbol)\(introPrice)/\(productUnit) (\(numberOfPeriods) \(productUnit)แรก)"
            }
        case "tr":
            if numberOfPeriods == 1 {
                return "Özel teklif: \(currencySymbol)\(introPrice)/\(productUnit) (ilk \(productUnit))"
            } else {
                return "Özel teklif: \(currencySymbol)\(introPrice)/\(productUnit) (ilk \(numberOfPeriods) \(productUnit))"
            }
        case "uk":
            if numberOfPeriods == 1 {
                return "Спеціальна пропозиція: \(currencySymbol)\(introPrice)/\(productUnit) (перший \(productUnit))"
            } else {
                return "Спеціальна пропозиція: \(currencySymbol)\(introPrice)/\(productUnit) (перші \(numberOfPeriods) \(productUnit)s)"
            }
        case "vi":
            if numberOfPeriods == 1 {
                return "Ưu đãi đặc biệt: \(currencySymbol)\(introPrice)/\(productUnit) (\(productUnit) đầu tiên)"
            } else {
                return "Ưu đãi đặc biệt: \(currencySymbol)\(introPrice)/\(productUnit) (\(numberOfPeriods) \(productUnit) đầu tiên)"
            }
        case "zh_Hans":
            if numberOfPeriods == 1 {
                return "限时优惠: 每\(productUnit)\(currencySymbol)\(introPrice)元（首\(productUnit)）"
            } else {
                return "限时优惠: 每\(productUnit)\(currencySymbol)\(introPrice)元（前\(numberOfPeriods)\(productUnit)）"
            }
        case "zh_Hant":
            if numberOfPeriods == 1 {
                return "限時優惠: 每\(productUnit)\(currencySymbol)\(introPrice)（首\(productUnit)）"
            } else {
                return "限時優惠: 每\(productUnit)\(currencySymbol)\(introPrice)（前\(numberOfPeriods)\(productUnit)）"
            }
        default:
            if numberOfPeriods == 1 {
                return "Special offer: \(currencySymbol)\(introPrice)/\(productUnit) (first \(productUnit))"
            } else {
                return "Special offer: \(currencySymbol)\(introPrice)/\(productUnit) (first \(numberOfPeriods) \(productUnit)s)"
            }
        }
    }
    
    /// 构建预付文本
    /// - Parameters:
    ///   - languageCode: 语言代码
    ///   - introPrice: 优惠价格字符串
    ///   - originalPrice: 原价字符串
    ///   - currencySymbol: 货币符号
    ///   - productUnit: 产品单位（本地化）
    /// - Returns: 格式化的预付文本
    private static func buildPayUpFrontText(languageCode: String, introPrice: String, originalPrice: String, currencySymbol: String, productUnit: String) -> String {
        // 计算折扣百分比
        let original = Double(originalPrice) ?? 0
        let discounted = Double(introPrice) ?? 0
        let discountPercent = original > 0 ? Int(((original - discounted) / original * 100).rounded()) : 0
        
        switch languageCode {
        case "ar":
            return "وفر \(discountPercent)%: \(currencySymbol)\(introPrice)/\(productUnit)"
        case "de":
            return "Spare \(discountPercent)%: \(currencySymbol)\(introPrice)/\(productUnit)"
        case "en":
            return "Save \(discountPercent)%: \(currencySymbol)\(introPrice)/\(productUnit)"
        case "es":
            return "Ahorra \(discountPercent)%: \(currencySymbol)\(introPrice)/\(productUnit)"
        case "fil":
            return "Makatipid ng \(discountPercent)%: \(currencySymbol)\(introPrice)/\(productUnit)"
        case "fr":
            return "Économisez \(discountPercent)%: \(currencySymbol)\(introPrice)/\(productUnit)"
        case "id":
            return "Hemat \(discountPercent)%: \(currencySymbol)\(introPrice)/\(productUnit)"
        case "it":
            return "Risparmia \(discountPercent)%: \(currencySymbol)\(introPrice)/\(productUnit)"
        case "ja":
            return "\(discountPercent)%OFF: \(currencySymbol)\(introPrice)/\(productUnit)"
        case "ko":
            return "\(discountPercent)% 할인: \(currencySymbol)\(introPrice)/\(productUnit)"
        case "pl":
            return "Zaoszczędź \(discountPercent)%: \(currencySymbol)\(introPrice)/\(productUnit)"
        case "pt":
            return "Economize \(discountPercent)%: \(currencySymbol)\(introPrice)/\(productUnit)"
        case "ru":
            return "Экономия \(discountPercent)%: \(currencySymbol)\(introPrice)/\(productUnit)"
        case "th":
            return "ประหยัด \(discountPercent)%: \(currencySymbol)\(introPrice)/\(productUnit)"
        case "tr":
            return "%\(discountPercent) tasarruf: \(currencySymbol)\(introPrice)/\(productUnit)"
        case "uk":
            return "Економія \(discountPercent)%: \(currencySymbol)\(introPrice)/\(productUnit)"
        case "vi":
            return "Tiết kiệm \(discountPercent)%: \(currencySymbol)\(introPrice)/\(productUnit)"
        case "zh_Hans":
            return "节省\(discountPercent)%: 每\(productUnit)\(currencySymbol)\(introPrice)元"
        case "zh_Hant":
            return "節省\(discountPercent)%: 每\(productUnit)\(currencySymbol)\(introPrice)"
        default:
            return "Save \(discountPercent)%: \(currencySymbol)\(introPrice)/\(productUnit)"
        }
    }
    
    /// 构建免费试用文本
    /// - Parameters:
    ///   - languageCode: 语言代码
    ///   - numberOfPeriods: 试用周期数量
    ///   - trialPeriodUnit: 试用周期单位（本地化）
    ///   - productUnit: 产品单位（本地化）
    ///   - price: 后续价格字符串
    ///   - currencySymbol: 货币符号
    /// - Returns: 格式化的免费试用文本
    private static func buildFreeTrialText(languageCode: String, numberOfPeriods: Int, trialPeriodUnit: String, productUnit: String, price: String, currencySymbol: String) -> String {
        switch languageCode {
        case "ar":
            return "تجربة مجانية \(numberOfPeriods) \(trialPeriodUnit)، ثم \(currencySymbol)\(price)/\(productUnit)"
        case "de":
            return "\(numberOfPeriods)-\(trialPeriodUnit)ige kostenlose Testphase, dann \(currencySymbol)\(price)/\(productUnit)"
        case "en":
            return "Free trial \(numberOfPeriods) \(trialPeriodUnit), then \(currencySymbol)\(price)/\(productUnit)"
        case "es":
            return "Prueba gratuita \(numberOfPeriods) \(trialPeriodUnit), luego \(currencySymbol)\(price)/\(productUnit)"
        case "fil":
            return "Libreng pagsubok \(numberOfPeriods) \(trialPeriodUnit), pagkatapos \(currencySymbol)\(price)/\(productUnit)"
        case "fr":
            return "Essai gratuit \(numberOfPeriods) \(trialPeriodUnit), puis \(currencySymbol)\(price)/\(productUnit)"
        case "id":
            return "Coba gratis \(numberOfPeriods) \(trialPeriodUnit), lalu \(currencySymbol)\(price)/\(productUnit)"
        case "it":
            return "Prova gratuita \(numberOfPeriods) \(trialPeriodUnit), poi \(currencySymbol)\(price)/\(productUnit)"
        case "ja":
            return "\(numberOfPeriods)\(trialPeriodUnit)無料トライアル、その後\(currencySymbol)\(price)/\(productUnit)"
        case "ko":
            return "\(numberOfPeriods)\(trialPeriodUnit) 무료 체험, 이후 \(currencySymbol)\(price)/\(productUnit)"
        case "pl":
            return "Bezpłatny okres próbny \(numberOfPeriods) \(trialPeriodUnit), następnie \(currencySymbol)\(price)/\(productUnit)"
        case "pt":
            return "Teste gratuito \(numberOfPeriods) \(trialPeriodUnit), depois \(currencySymbol)\(price)/\(productUnit)"
        case "ru":
            return "Бесплатная пробная версия \(numberOfPeriods) \(trialPeriodUnit), затем \(currencySymbol)\(price)/\(productUnit)"
        case "th":
            return "ทดลองใช้ฟรี \(numberOfPeriods) \(trialPeriodUnit) จากนั้น \(currencySymbol)\(price)/\(productUnit)"
        case "tr":
            return "\(numberOfPeriods) \(trialPeriodUnit) ücretsiz deneme, sonrasında \(currencySymbol)\(price)/\(productUnit)"
        case "uk":
            return "Безкоштовна пробна версія \(numberOfPeriods) \(trialPeriodUnit), потім \(currencySymbol)\(price)/\(productUnit)"
        case "vi":
            return "Dùng thử miễn phí \(numberOfPeriods) \(trialPeriodUnit), sau đó \(currencySymbol)\(price)/\(productUnit)"
        case "zh_Hans":
            return "免费试用 \(numberOfPeriods) \(trialPeriodUnit)，然后每\(productUnit)\(currencySymbol)\(price)元"
        case "zh_Hant":
            return "免費試用 \(numberOfPeriods) \(trialPeriodUnit)，然後每\(productUnit)\(currencySymbol)\(price)"
        default:
            return "Free trial \(numberOfPeriods) \(trialPeriodUnit), then \(currencySymbol)\(price)/\(productUnit)"
        }
    }
}

