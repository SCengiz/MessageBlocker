import Foundation

enum KeywordStore {
    static let appGroupID = "group.com.soraycengiz.MessageBlocker"
    private static let key = "blockedKeywords"
    private static let defaultKeywords = ["mt2", "metin2", "server"]

    private static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }

    static func load() -> [String] {
        defaults.stringArray(forKey: key) ?? defaultKeywords
    }

    static func save(_ keywords: [String]) {
        defaults.set(keywords, forKey: key)
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
