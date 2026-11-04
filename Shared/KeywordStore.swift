import Foundation

enum KeywordStore {
    static let appGroupID = "group.com.soraycengiz.MessageBlocker"
    private static let key = "blockedKeywords"
    private static let defaultKeywords = ["mt2", "metin2", "server"]

    private static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    /// Kurallar hem App Group deposuna hem de uygulamanın kendi deposuna yazılır.
    /// Ücretsiz geliştirici hesaplarında App Group yetkisi her zaman çalışmadığı
    /// için, yerel kopya kuralların kaybolmasını önleyen yedek görevi görür.
    static func load() -> [String] {
        if let shared = sharedDefaults?.stringArray(forKey: key), !shared.isEmpty {
            return shared
        }
        if let local = UserDefaults.standard.stringArray(forKey: key), !local.isEmpty {
            // App Group okunamadıysa yerel kopyayı geri yazmayı dene
            sharedDefaults?.set(local, forKey: key)
            return local
        }
        return defaultKeywords
    }

    static func save(_ keywords: [String]) {
        sharedDefaults?.set(keywords, forKey: key)
        UserDefaults.standard.set(keywords, forKey: key)
    }

    // MARK: - 0850 numara engelleme

    private static let block0850Key = "block0850Senders"

    static func isBlocking0850() -> Bool {
        if let shared = sharedDefaults?.object(forKey: block0850Key) as? Bool {
            return shared
        }
        return UserDefaults.standard.bool(forKey: block0850Key)
    }

    static func setBlocking0850(_ enabled: Bool) {
        sharedDefaults?.set(enabled, forKey: block0850Key)
        UserDefaults.standard.set(enabled, forKey: block0850Key)
    }

    /// Gönderen numarası 0850 ile başlıyor mu? Numara +90 850..., 0850...
    /// veya 850... biçimlerinde gelebildiği için hepsi kontrol edilir.
    static func isSender0850(_ sender: String) -> Bool {
        let digits = sender.filter(\.isNumber)
        return digits.hasPrefix("90850") || digits.hasPrefix("0850") || digits.hasPrefix("850")
    }

    // MARK: - 0850 çağrı engelleme

    private static let block0850CallsKey = "block0850Calls"

    /// +90 850 XXX XX XX aralığı: engelleme listesine eklenecek numaralar.
    /// CallKit joker/önek kabul etmediği için aralığın tamamı tek tek eklenir.
    static let calls0850Start: Int64 = 908_500_000_000
    static let calls0850End: Int64 = 908_509_999_999

    static func isBlocking0850Calls() -> Bool {
        if let shared = sharedDefaults?.object(forKey: block0850CallsKey) as? Bool {
            return shared
        }
        return UserDefaults.standard.bool(forKey: block0850CallsKey)
    }

    static func setBlocking0850Calls(_ enabled: Bool) {
        sharedDefaults?.set(enabled, forKey: block0850CallsKey)
        UserDefaults.standard.set(enabled, forKey: block0850CallsKey)
    }

    // MARK: - Eşleştirme

    /// Mesajın engellenmesi gerekip gerekmediğini söyler.
    static func shouldBlock(sender: String?, body: String?) -> Bool {
        if isBlocking0850(), let sender, isSender0850(sender) {
            return true
        }
        if let body, matches(body) {
            return true
        }
        return false
    }

    static func matches(_ messageBody: String) -> Bool {
        let body = normalize(messageBody)
        return load().contains { keyword in
            let needle = normalize(keyword)
            return !needle.isEmpty && body.contains(needle)
        }
    }

    /// Türkçe İ/I/ı/i harflerinin hepsini tek forma indirger, ardından diğer
    /// harfler için standart büyük/küçük harf ve aksan farkını yok sayar.
    /// Böylece "metin2", "Metin2", "METİN2", "metın2" hepsi aynı kural sayılır.
    private static func normalize(_ s: String) -> String {
        let turkishIFolded = String(s.map { char -> Character in
            switch char {
            case "İ", "I", "ı", "i":
                return "i"
            default:
                return char
            }
        })
        return turkishIFolded.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "en_US"))
    }
}
