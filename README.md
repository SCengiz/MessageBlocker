# MessageBlocker

Kural bazlı SMS/MMS filtreleme uygulaması. Gelen bir mesajın içinde tanımladığın anahtar kelimelerden biri geçiyorsa, mesaj sana bildirim olarak gösterilmeden **Bilinmeyen ve İstenmeyen** klasörüne taşınır.

## Nasıl çalışır

- Ana uygulamada kural (anahtar kelime) listesi tutulur, ekleyip silebilirsin.
- Apple'ın [Message Filter Extension](https://developer.apple.com/documentation/identitylookup/creating-a-message-filter-app-extension) API'si (`ILMessageFilterExtension`) kullanılıyor: gelen her SMS/MMS, bildirim gösterilmeden önce bu extension'a soruluyor.
- Mesaj gövdesinde kurallardan biri geçiyorsa mesaj `.junk` olarak işaretlenir ve bildirim hiç gösterilmez.
- Eşleştirme büyük/küçük harf ve Türkçe İ/I/ı/i farkına duyarsızdır: `metin2` kuralı `Metin2`, `METİN2`, `metın2` gibi tüm yazımları da yakalar.

## Proje yapısı

- `MessageBlocker/` — ana uygulama, kural listesi ekranı (`ContentView.swift`)
- `MessageFilterExtension/` — mesaj filtreleme extension'ı (`ILMessageFilterExtension`)
- `Shared/KeywordStore.swift` — iki hedef arasında App Group (`group.com.soraycengiz.MessageBlocker`) ile paylaşılan kural deposu ve eşleştirme mantığı
- `project.yml` — [XcodeGen](https://github.com/yonaskolb/XcodeGen) proje tanımı; `.xcodeproj` bu dosyadan üretilir (`xcodegen generate`)

## Geliştirme

```bash
xcodegen generate
xcodebuild -project MessageBlocker.xcodeproj -scheme MessageBlocker -destination 'generic/platform=iOS Simulator' build
```

Gerçek cihaza kurmak için:

```bash
xcodebuild -project MessageBlocker.xcodeproj -scheme MessageBlocker -destination 'id=<CIHAZ_ID>' -allowProvisioningUpdates build
xcrun devicectl device install app --device <CIHAZ_ID> <APP_YOLU>
```

## Cihazda filtrelemeyi aktif etme

Filtrelemenin gerçekten çalışması için, uygulamayı kurduktan sonra iPhone'da şu adımlar gerekiyor (iOS 26):

1. **Mesajlar** uygulamasını aç
2. Yazışma listesinin sağ üstündeki filtre simgesine dokun, **"Filtrelemeyi Yönet"**e dokun
3. **"Bilinmeyen Gönderenleri Tara"**yı aç
4. Aynı ekranda tekrar filtre simgesine dokun, **"Mesaj Filtresi"**ne dokun, sonra **"Mesaj Filtresi"**ni ve **MessageBlocker**'ı aç

**Önemli sınırlamalar:**
- Bu filtre yalnızca **SMS/MMS** mesajlarını yakalar, **iMessage**'ı yakalamaz.
- Filtre, en az 3 kez yazıştığın/cevap verdiğin gönderenlere uygulanmaz — sadece bilinmeyen/yeni gönderenlerden gelen mesajlarda çalışır.
- Filtreleme yalnızca mesaj **geldiği anda** çalışır; önceden gelmiş bir mesajı geriye dönük filtrelemez.
- Simülatörde gerçek SMS alınamadığı için filtrelemeyi yalnızca gerçek cihazda test edebilirsin.
