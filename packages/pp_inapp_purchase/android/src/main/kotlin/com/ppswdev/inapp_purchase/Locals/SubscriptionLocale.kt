package com.ppswdev.inapp_purchase

import java.text.NumberFormat
import java.util.Currency
import java.util.Locale

/**
 * Android subscription copy aligned with the StoreKit2Manager locale structure.
 *
 * Google Play supplies localized product names and formatted prices, while this helper owns the
 * app-defined plan labels, benefit descriptions, and purchase button text shared by the two stores.
 */
internal object SubscriptionLocale {
    enum class PeriodType {
        WEEK,
        MONTH,
        YEAR,
        LIFETIME
    }

    enum class ButtonType {
        STANDARD,
        FREE_TRIAL,
        PAY_UP_FRONT,
        PAY_AS_YOU_GO,
        LIFETIME
    }

    data class Price(
        val amountMicros: Long,
        val currencyCode: String,
        val formattedPrice: String
    )

    data class IntroductoryPrice(
        val price: Price,
        val periodCount: Int,
        val periodUnit: String,
        val billingCycleCount: Int,
        val buttonType: ButtonType
    )

    private val titles =
        mapOf(
            "ar" to listOf("اشتراك أسبوعي", "اشتراك شهري", "اشتراك سنوي", "اشتراك مدى الحياة"),
            "de" to listOf("Wöchentliches Abo", "Monatliches Abo", "Jährliches Abo", "Lebenslanges Abo"),
            "en" to listOf("Weekly Subscription", "Monthly Subscription", "Annual Subscription", "Lifetime Membership"),
            "es" to listOf("Suscripción semanal", "Suscripción mensual", "Suscripción anual", "Suscripción de por vida"),
            "fil" to listOf("Lingguhang Subscription", "Buwanang Subscription", "Taunang Subscription", "Panghabang-buhay na Subscription"),
            "fr" to listOf("Abonnement hebdomadaire", "Abonnement mensuel", "Abonnement annuel", "Abonnement à vie"),
            "id" to listOf("Langganan mingguan", "Langganan bulanan", "Langganan tahunan", "Langganan seumur hidup"),
            "it" to listOf("Abbonamento settimanale", "Abbonamento mensile", "Abbonamento annuale", "Abbonamento a vita"),
            "ja" to listOf("週額プラン", "月額プラン", "年額プラン", "生涯プラン"),
            "ko" to listOf("주간 구독", "월간 구독", "연간 구독", "평생 회원권"),
            "pl" to listOf("Subskrypcja tygodniowa", "Subskrypcja miesięczna", "Subskrypcja roczna", "Subskrypcja dożywotnia"),
            "pt" to listOf("Assinatura semanal", "Assinatura mensal", "Assinatura anual", "Assinatura vitalícia"),
            "ru" to listOf("Еженедельная подписка", "Ежемесячная подписка", "Годовая подписка", "Пожизненная подписка"),
            "th" to listOf("สมัครสมาชิกแบบรายสัปดาห์", "สมัครสมาชิกแบบรายเดือน", "สมัครสมาชิกแบบรายปี", "สมาชิกตลอดชีพ"),
            "tr" to listOf("Haftalık abonelik", "Aylık abonelik", "Yıllık abonelik", "Ömür boyu abonelik"),
            "uk" to listOf("Тижнева підписка", "Місячна підписка", "Річна підписка", "Довічна підписка"),
            "vi" to listOf("Gói thuê bao hàng tuần", "Gói thuê bao hàng tháng", "Gói thuê bao hàng năm", "Gói trọn đời"),
            "zh_Hans" to listOf("每周会员", "每月会员", "年度会员", "终身会员"),
            "zh_Hant" to listOf("每週會員", "每月會員", "年度會員", "終身會員")
        )

    private val descriptions =
        mapOf(
            "ar" to listOf("مرونة", "قيمة ممتازة", "الأكثر توفيراً", "اشتراك دائم بدون تجديد"),
            "de" to listOf("Flexibilität", "Bester Wert", "Meist gespart", "Einmalig zahlen, dauerhaft nutzen"),
            "en" to listOf("Flexible", "Best Value", "Most Popular", "Pay once, own forever"),
            "es" to listOf("Flexible", "Mejor Valor", "Más Popular", "Paga una vez, disfruta siempre"),
            "fil" to listOf("Nakakalag", "Pinakamahusay na Halaga", "Pinakasikat", "Isang beses lang, habambuhay na"),
            "fr" to listOf("Flexible", "Meilleur Rapport", "Plus Populaire", "Achetez une fois, profitez à vie"),
            "id" to listOf("Fleksibel", "Nilai Terbaik", "Paling Populer", "Bayar sekali, pakai selamanya"),
            "it" to listOf("Flessibile", "Miglior Valore", "Più Popolare", "Paga una volta, usa per sempre"),
            "ja" to listOf("柔軟性", "お得", "人気", "一度の支払いで永久利用"),
            "ko" to listOf("유연함", "최고 가치", "인기", "한 번 결제로 평생 이용"),
            "pl" to listOf("Elastyczność", "Najlepsza Wartość", "Najpopularniejsze", "Zapłać raz, korzystaj zawsze"),
            "pt" to listOf("Flexível", "Melhor Valor", "Mais Popular", "Pague uma vez, use para sempre"),
            "ru" to listOf("Гибкость", "Лучшая Цена", "Популярный", "Оплати один раз, используй всегда"),
            "th" to listOf("ยืดหยุ่น", "คุ้มค่าที่สุด", "ยอดนิยม", "จ่ายครั้งเดียว ใช้ได้ตลอดชีพ"),
            "tr" to listOf("Esnek", "En İyi Değer", "En Popüler", "Bir kez öde, sürekli kullan"),
            "uk" to listOf("Гнучкість", "Найкраща Ціна", "Популярний", "Сплати один раз, використовуй завжди"),
            "vi" to listOf("Linh hoạt", "Giá trị tốt nhất", "Phổ biến nhất", "Thanh toán một lần, sử dụng mãi mãi"),
            "zh_Hans" to listOf("灵活选择", "性价比之选", "最优惠", "一次购买，终身访问"),
            "zh_Hant" to listOf("靈活選擇", "性價比之選", "最優惠", "一次購買，終生訪問")
        )

    private val buttons =
        mapOf(
            "ar" to listOf("اشترك", "جرّب مجانًا", "ادفع الآن", "ادفع حسب الاستخدام", "اشتر مدى الحياة"),
            "de" to listOf("Abonnieren", "Kostenlos testen", "Jetzt bezahlen", "Bezahlen nach Nutzung", "Lebenslang kaufen"),
            "en" to listOf("Subscribe", "Start Free Trial", "Prepay Now", "Pay As You Go", "Buy Lifetime"),
            "es" to listOf("Suscribirse", "Prueba gratis", "Pagar ahora", "Pagar por uso", "Comprar de por vida"),
            "fil" to listOf("Mag-subscribe", "Subukan nang libre", "Magbayad ngayon", "Magbayad ayon sa paggamit", "Bilhin ang panghabang-buhay"),
            "fr" to listOf("S'abonner", "Essai gratuit", "Payer maintenant", "Payer à l'usage", "Acheter à vie"),
            "id" to listOf("Berlangganan", "Coba gratis", "Bayar sekarang", "Bayar sesuai pemakaian", "Beli seumur hidup"),
            "it" to listOf("Abbonati", "Prova gratuita", "Paga ora", "Paga a consumo", "Acquista a vita"),
            "ja" to listOf("購読する", "無料トライアル開始", "今すぐ支払う", "使った分だけ支払う", "生涯購入"),
            "ko" to listOf("구독하기", "무료 체험 시작", "지금 결제", "사용한 만큼 결제", "평생 구매"),
            "pl" to listOf("Subskrybuj", "Wypróbuj za darmo", "Zapłać teraz", "Płać zgodnie z użyciem", "Kup na całe życie"),
            "pt" to listOf("Assinar", "Teste grátis", "Pagar agora", "Pagar conforme o uso", "Comprar vitalício"),
            "ru" to listOf("Подписаться", "Попробовать бесплатно", "Оплатить сейчас", "Оплата по мере использования", "Купить навсегда"),
            "th" to listOf("สมัครสมาชิก", "ทดลองใช้ฟรี", "ชำระตอนนี้", "จ่ายตามการใช้งาน", "ซื้อตลอดชีพ"),
            "tr" to listOf("Abone ol", "Ücretsiz dene", "Şimdi öde", "Kullandıkça öde", "Yaşam boyu satın al"),
            "uk" to listOf("Підписатися", "Спробувати безкоштовно", "Оплатити зараз", "Оплата за мірою використання", "Купити назавжди"),
            "vi" to listOf("Đăng ký", "Dùng thử miễn phí", "Thanh toán ngay", "Trả theo nhu cầu", "Mua trọn đời"),
            "zh_Hans" to listOf("订阅", "开始免费试用", "立即支付", "按需付费", "购买终身"),
            "zh_Hant" to listOf("訂閱", "開始免費試用", "立即支付", "按需付費", "購買終身")
        )

    fun periodType(value: String?): PeriodType =
        when (value?.lowercase(Locale.US)) {
            "week" -> PeriodType.WEEK
            "month" -> PeriodType.MONTH
            "year" -> PeriodType.YEAR
            "lifetime" -> PeriodType.LIFETIME
            else -> PeriodType.WEEK
        }

    fun title(
        periodType: PeriodType,
        languageCode: String?
    ): String = localized(titles, languageCode)[periodType.ordinal]

    fun buttonText(
        buttonType: ButtonType,
        languageCode: String?
    ): String = localized(buttons, languageCode)[buttonType.ordinal]

    fun subtitle(
        periodType: PeriodType,
        languageCode: String?,
        basePrice: Price?,
        introductoryPrice: IntroductoryPrice?
    ): String {
        val language = normalizedLanguage(languageCode)
        val description = localized(descriptions, language)[periodType.ordinal]
        if (periodType == PeriodType.LIFETIME || basePrice == null) {
            return description
        }

        if (introductoryPrice != null) {
            val introText =
                when (introductoryPrice.buttonType) {
                    ButtonType.FREE_TRIAL ->
                        freeTrialText(
                            language,
                            introductoryPrice.periodCount,
                            introductoryPrice.periodUnit
                        )
                    ButtonType.PAY_UP_FRONT ->
                        "${introductoryPrice.price.formattedPrice} ${localizedPayUpFront(language)}"
                    ButtonType.PAY_AS_YOU_GO ->
                        "${introductoryPrice.price.formattedPrice}/${localizedUnit(language, introductoryPrice.periodUnit, 1)}"
                    else -> introductoryPrice.price.formattedPrice
                }
            return "$introText, ${localizedThen(language)} ${basePrice.formattedPrice}/${localizedUnit(language, periodType.name.lowercase(Locale.US), 1)}"
        }

        val priceText =
            when (periodType) {
                PeriodType.MONTH ->
                    "${basePrice.formattedPrice}/${localizedUnit(language, "month", 1)} · ~${formatPrice(basePrice, 4.0, language)}/${localizedUnit(language, "week", 1)}"
                PeriodType.YEAR ->
                    "${basePrice.formattedPrice}/${localizedUnit(language, "year", 1)} · ${localizedOnly(language)} ${formatPrice(basePrice, 52.0, language)}/${localizedUnit(language, "week", 1)}"
                else ->
                    "${basePrice.formattedPrice}/${localizedUnit(language, "week", 1)}"
            }
        return "$description, $priceText"
    }

    private fun <T> localized(
        values: Map<String, T>,
        languageCode: String?
    ): T = values[normalizedLanguage(languageCode)] ?: values.getValue("en")

    private fun normalizedLanguage(languageCode: String?): String {
        val raw = languageCode?.replace('-', '_').orEmpty()
        val lower = raw.lowercase(Locale.US)
        return when {
            lower.startsWith("zh_hant") ||
                lower.startsWith("zh_tw") ||
                lower.startsWith("zh_hk") -> "zh_Hant"
            lower.startsWith("zh") -> "zh_Hans"
            else -> lower.substringBefore('_').takeIf { it in titles.keys } ?: "en"
        }
    }

    private fun formatPrice(
        price: Price,
        divisor: Double,
        languageCode: String
    ): String {
        val formatter = NumberFormat.getCurrencyInstance(localeFor(languageCode))
        runCatching { formatter.currency = Currency.getInstance(price.currencyCode) }
        return formatter.format(price.amountMicros.toDouble() / 1_000_000.0 / divisor)
    }

    private fun localeFor(languageCode: String): Locale =
        when (languageCode) {
            "zh_Hans" -> Locale.SIMPLIFIED_CHINESE
            "zh_Hant" -> Locale.TRADITIONAL_CHINESE
            "fil" -> Locale.forLanguageTag("fil")
            else -> Locale.forLanguageTag(languageCode)
        }

    private fun localizedUnit(
        languageCode: String,
        unit: String,
        count: Int
    ): String {
        val normalizedUnit =
            when (unit.lowercase(Locale.US)) {
                "day", "week", "month", "year" -> unit.lowercase(Locale.US)
                else -> "day"
            }
        val units =
            mapOf(
                "ar" to listOf("يوم", "أسبوع", "شهر", "سنة"),
                "de" to listOf("Tag", "Woche", "Monat", "Jahr"),
                "en" to listOf("day", "week", "month", "year"),
                "es" to listOf("día", "semana", "mes", "año"),
                "fil" to listOf("araw", "linggo", "buwan", "taon"),
                "fr" to listOf("jour", "semaine", "mois", "an"),
                "id" to listOf("hari", "minggu", "bulan", "tahun"),
                "it" to listOf("giorno", "settimana", "mese", "anno"),
                "ja" to listOf("日", "週", "月", "年"),
                "ko" to listOf("일", "주", "개월", "년"),
                "pl" to listOf("dzień", "tydzień", "miesiąc", "rok"),
                "pt" to listOf("dia", "semana", "mês", "ano"),
                "ru" to listOf("день", "неделя", "месяц", "год"),
                "th" to listOf("วัน", "สัปดาห์", "เดือน", "ปี"),
                "tr" to listOf("gün", "hafta", "ay", "yıl"),
                "uk" to listOf("день", "тиждень", "місяць", "рік"),
                "vi" to listOf("ngày", "tuần", "tháng", "năm"),
                "zh_Hans" to listOf("天", "周", "月", "年"),
                "zh_Hant" to listOf("天", "週", "月", "年")
            )
        val index = listOf("day", "week", "month", "year").indexOf(normalizedUnit)
        val base = localized(units, languageCode)[index]
        return if (languageCode == "en" && count != 1) "${base}s" else base
    }

    private fun freeTrialText(
        languageCode: String,
        count: Int,
        unit: String
    ): String {
        val duration = "$count ${localizedUnit(languageCode, unit, count)}"
        return when (languageCode) {
            "ar" -> "مجانًا لمدة $duration"
            "de" -> "$duration kostenlos"
            "es" -> "Gratis durante $duration"
            "fil" -> "Libre sa loob ng $duration"
            "fr" -> "Gratuit pendant $duration"
            "id" -> "Gratis selama $duration"
            "it" -> "Gratis per $duration"
            "ja" -> "${duration}無料"
            "ko" -> "$duration 무료"
            "pl" -> "Bezpłatnie przez $duration"
            "pt" -> "Grátis por $duration"
            "ru" -> "Бесплатно на $duration"
            "th" -> "ฟรี $duration"
            "tr" -> "$duration ücretsiz"
            "uk" -> "Безкоштовно на $duration"
            "vi" -> "Miễn phí trong $duration"
            "zh_Hans" -> "免费试用$duration"
            "zh_Hant" -> "免費試用$duration"
            else -> "Free for $duration"
        }
    }

    private fun localizedThen(languageCode: String): String =
        mapOf(
            "ar" to "ثم",
            "de" to "danach",
            "es" to "después",
            "fil" to "pagkatapos",
            "fr" to "puis",
            "id" to "lalu",
            "it" to "poi",
            "ja" to "その後",
            "ko" to "이후",
            "pl" to "potem",
            "pt" to "depois",
            "ru" to "затем",
            "th" to "จากนั้น",
            "tr" to "sonra",
            "uk" to "потім",
            "vi" to "sau đó",
            "zh_Hans" to "之后",
            "zh_Hant" to "之後"
        )[languageCode] ?: "then"

    private fun localizedOnly(languageCode: String): String =
        mapOf(
            "ar" to "فقط",
            "de" to "nur",
            "es" to "solo",
            "fil" to "lang",
            "fr" to "seulement",
            "id" to "hanya",
            "it" to "solo",
            "ja" to "わずか",
            "ko" to "단",
            "pl" to "tylko",
            "pt" to "apenas",
            "ru" to "всего",
            "th" to "เพียง",
            "tr" to "sadece",
            "uk" to "лише",
            "vi" to "chỉ",
            "zh_Hans" to "仅",
            "zh_Hant" to "僅"
        )[languageCode] ?: "only"

    private fun localizedPayUpFront(languageCode: String): String =
        mapOf(
            "ar" to "مدفوعة مقدمًا",
            "de" to "im Voraus",
            "es" to "por adelantado",
            "fil" to "paunang bayad",
            "fr" to "payé d'avance",
            "id" to "dibayar di muka",
            "it" to "in anticipo",
            "ja" to "前払い",
            "ko" to "선불",
            "pl" to "z góry",
            "pt" to "antecipado",
            "ru" to "авансом",
            "th" to "ชำระล่วงหน้า",
            "tr" to "peşin",
            "uk" to "наперед",
            "vi" to "trả trước",
            "zh_Hans" to "预付",
            "zh_Hant" to "預付"
        )[languageCode] ?: "up front"
}
