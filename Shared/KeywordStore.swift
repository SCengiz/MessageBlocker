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
        let body = messageBody.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "tr_TR"))
        return load().contains { keyword in
            let needle = keyword.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "tr_TR"))
            return !needle.isEmpty && body.contains(needle)
        }
    }
}
