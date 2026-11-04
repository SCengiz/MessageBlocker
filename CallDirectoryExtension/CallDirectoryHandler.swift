import Foundation
import CallKit

/// 0850 ile başlayan numaralardan gelen çağrıları engeller.
///
/// CallKit önek/joker desteklemediği için aralıktaki numaralar tek tek
/// eklenmek zorunda: +90 850 0000000 ... +90 850 9999999 (10 milyon numara).
/// Numaralar artan sırada eklenmeli; döngü ek bellek kullanmaz.
final class CallDirectoryHandler: CXCallDirectoryProvider {

    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        context.delegate = self

        // Artımlı güncelleme desteklenmiyor: her seferinde listeyi baştan kur.
        if context.isIncremental {
            context.removeAllBlockingEntries()
        }

        if KeywordStore.isBlocking0850Calls() {
            var number = KeywordStore.calls0850Start
            let end = KeywordStore.calls0850End
            while number <= end {
                context.addBlockingEntry(withNextSequentialPhoneNumber: number)
                number += 1
            }
        }

        context.completeRequest()
    }
}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {
    func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error) {
        // Sistem hatayı burada bildirir (ör. numara sayısı sınırı aşılırsa).
        NSLog("CallDirectory isteği başarısız: \(error.localizedDescription)")
    }
}
