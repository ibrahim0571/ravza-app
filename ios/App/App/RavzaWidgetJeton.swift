// iOS ana ekran widget jetonu köprüsü (3 Kas 2026).
// Web (Ravza) girişliyken /api/user/widget-jeton'dan aldığı jetonu buraya verir; jeton ORTAK anahtar zincirine
// (TeamID.com.ibrahimaktas.ravza.paylasim) yazılır, RavzaWidgets eklentisi aynı gruptan okur. App Group gerekmez.
import Foundation
import Capacitor
import Security
import WidgetKit
import UserNotifications

enum RzAnahtar {
    static let grup = "ZU23KJAUGH.com.ibrahimaktas.ravza.paylasim"
    static let hesap = "ravza.widget.jeton"
    static func yaz(_ deger: String?) {
        let temel: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrAccount as String: hesap, kSecAttrAccessGroup as String: grup]
        SecItemDelete(temel as CFDictionary)
        guard let d = deger, !d.isEmpty else { return }
        var ekle = temel
        ekle[kSecValueData as String] = Data(d.utf8)
        ekle[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        SecItemAdd(ekle as CFDictionary, nil)
    }
}

@objc(RavzaWidgetJeton)
public class RavzaWidgetJeton: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "RavzaWidgetJeton"
    public let jsName = "RavzaWidgetJeton"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "ayarla", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "sil", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "yenile", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "ayarlar", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "rozet", returnType: CAPPluginReturnPromise),
    ]
    @objc func ayarla(_ call: CAPPluginCall) {
        RzAnahtar.yaz(call.getString("jeton"))
        WidgetCenter.shared.reloadAllTimelines()
        call.resolve(["ok": true])
    }
    @objc func sil(_ call: CAPPluginCall) {
        RzAnahtar.yaz(nil)
        WidgetCenter.shared.reloadAllTimelines()
        call.resolve(["ok": true])
    }
    @objc func yenile(_ call: CAPPluginCall) {
        WidgetCenter.shared.reloadAllTimelines()
        call.resolve(["ok": true])
    }
    /// 26 Kas (İbrahim: "ayarlardan izin vermeye götürsün"): Ravza'nın iOS Ayarlar sayfası (kamera, konum, hareket, bildirim izinleri).
    @objc func ayarlar(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            if let u = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(u) }
            call.resolve(["ok": true])
        }
    }
    /// 26 Kas: uygulama simgesi rozeti = okunmamış bildirim sayısı (site zil sayısıyla aynı). 0 = rozeti kaldır.
    @objc func rozet(_ call: CAPPluginCall) {
        let n = max(0, call.getInt("n") ?? 0)
        DispatchQueue.main.async {
            if #available(iOS 16.0, *) { UNUserNotificationCenter.current().setBadgeCount(n) }
            else { UIApplication.shared.applicationIconBadgeNumber = n }
            if n == 0 { UNUserNotificationCenter.current().removeAllDeliveredNotifications() }
            call.resolve(["ok": true])
        }
    }
}

/// Capacitor 6: yerel eklentiyi köprüye kaydeder (storyboard bu sınıfı kullanır).
class RavzaKopruVC: CAPBridgeViewController {
    override open func capacitorDidLoad() {
        bridge?.registerPluginInstance(RavzaWidgetJeton())
    }
}
