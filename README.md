# 🕌 Ravza Native App (Capacitor)

Ravza — İslami Yaşam Platformu resmi native uygulaması. **Android + iOS** tek kod tabanı.

## Mimari
- **Capacitor server mode**: app, canlı Ravza sitesini (`tesbihat.ibrahimaktas.com`) native kabuk içinde açar. SSR + API routes + Supabase auth sorunsuz çalışır (static export gerekmez).
- **Native güçler**: push bildirim (ezan/vird), haptik titreşim (zikir), BLE (akıllı zikir yüzük/saat), status bar, splash, network durumu.
- **appId**: `com.ibrahimaktas.ravza`

## Klasör
```
ravza-app/
├── capacitor.config.json   # ana config (server url, splash, push)
├── package.json            # capacitor + pluginler
├── www/                    # placeholder web dir (server mode'da minimal)
└── .github/workflows/
    └── build.yml           # GitHub Actions cloud build (APK + IPA)
```

## 🚀 Build (2 yol)

### A) GitHub Actions (Mac/SDK GEREKMEZ — ÖNERİ)
1. Bu klasörü bir GitHub repo'ya push et
2. Actions sekmesi → "Ravza Native App Build" → Run workflow
3. **Android**: ubuntu runner'da APK üretilir (imzalı AAB için keystore secret ekle)
4. **iOS**: macos runner'da derlenir (App Store için Apple Developer hesabı + fastlane gerekli)
5. Artifacts'tan APK/AAB indir

**Gerekli secrets (imzalı release için):**
- `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`

### B) Yerel (bir bilgisayarda)
```bash
cd ravza-app
npm install
# Android (Android Studio gerekli):
npm run android
# iOS (Mac + Xcode gerekli):
npm run ios
```

## 📿 Sonraki adımlar (yol haritası)
- Faz 2 ✅ BLE (Web Bluetooth kartı canlı — /akilli-cihaz)
- Faz 3: Ravza yüzük özel protokolü + native BLE plugin (@capacitor-community/bluetooth-le)
- Faz 4: Apple Watch (WatchOS) + Wear OS companion app
- Faz 5: Ravza markalı yüzük (Equantu OEM)

## 🎨 Kimlik
- Splash/status: Medine yeşili `#0e6b58`
- İkon: gerçek Ravza Yeşil Kubbe (Mescid-i Nebevî)

---
🕌 Ravza · İbrahim Aktaş · Ultra premium native app
