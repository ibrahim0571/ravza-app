# Ravza Wearable Companion — Faz 4 (Apple Watch + Wear OS)

> **Durum:** İskelet + kurulum rehberi hazır. Gerçek watch build'i için Xcode (WatchOS) ve Android Studio (Wear OS) gerekir. Bu klasör companion mimarisini ve entegrasyon planını içerir.

## Amaç

Akıllı saatte (Apple Watch / Wear OS) tesbih çek → telefon Ravza app'e sinyal → Ravza sayaç API'ye işlensin → lig / dergâh mertebe / himmet / Ümmet havuzu **otomatik artsın**.

Bu, Ravza Yüzük (BLE) ile aynı sayaç sistemine bağlanır: `/api/user/zikirmatik-say` → `record_worship`.

## Mimari (Kanka Gemini + Codex mutabık)

```
[Saat: TAP butonu]
      │  (WatchConnectivity / Wearable MessageClient)
      ▼
[Telefon native: sinyal dinleyici]
      │  (Capacitor plugin → webview event 'ravza:dhikr')
      ▼
[Ravza webview: zikirKaydet(delta)]
      │  POST /api/user/zikirmatik-say
      ▼
[record_worship → sayaç + lig + dergâh + himmet + Ümmet]
```

## 1. Apple Watch (WatchOS)

**Kurulum (Xcode gerekir):**
1. `npx cap add ios` sonrası `ios/App/App.xcworkspace` aç.
2. File → New → Target → **Watch App** (SwiftUI).
3. Bundle ID: `com.ibrahimaktas.ravza.watchkitapp`.
4. UI: tek büyük "Zikir Çek" butonu + sayaç (`watch/RavzaWatchApp.swift` örneği).
5. İletişim: **WatchConnectivity** — `WCSession.default.sendMessage(["dhikr": 1])`.
6. iOS tarafı: `AppDelegate`/plugin `WCSessionDelegate` ile dinler → webview'a `ravza:dhikr` event fırlatır.

Örnek dosyalar:
- `watch/RavzaWatchApp.swift` — SwiftUI arayüz + WCSession gönderim
- `ios-bridge/WatchBridgePlugin.swift` — Capacitor plugin, mesaj → webview köprüsü

## 2. Wear OS (Android)

**Kurulum (Android Studio gerekir):**
1. `npx cap add android` sonrası `android/` aç.
2. File → New → New Module → **Wear OS Module** (`wear`).
3. `applicationId` telefon app ile aynı köke sahip.
4. UI: Compose for Wear OS — tek büyük buton (`wear/MainActivity.kt` örneği).
5. İletişim: **Wearable MessageClient** — `Wearable.getMessageClient(context).sendMessage(node, "/ravza-dhikr", data)`.
6. Telefon tarafı: `WearableListenerService` → webview'a `ravza:dhikr` event.

Örnek dosyalar:
- `wear/MainActivity.kt` — Compose buton + MessageClient gönderim
- `android-bridge/WearBridgeService.kt` — telefon dinleyici → webview köprüsü

## 3. MVP (en basit yol)

Saat sadece **tek yönlü "1 sayım" sinyali** gönderir. Telefon app native kısmı bu sinyali `window.dispatchEvent(new CustomEvent('ravza:dhikr'))` ile webview'a iletir; mevcut `native-bridge.tsx` zaten bu event'i dinliyor (haptik + sayaç). Sayaç artışı `zikirmatik-say` API'sine gider.

**Not:** Telefon `native-bridge.tsx` içindeki `ravza:dhikr` event'i haptik veriyor; wearable sinyali de aynı event'i tetikleyerek mevcut akışa bağlanır. Ekstra API gerekmez.

## Sonraki adım

İbrahim'in Mac (Xcode) + Android Studio ortamında:
1. Watch/Wear target'ları eklenir
2. Örnek Swift/Kotlin dosyaları kopyalanır
3. Bundle/app ID ayarlanır
4. Build + gerçek saatte test

Bu klasördeki örnek dosyalar başlangıç şablonudur.
