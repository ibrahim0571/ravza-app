// iOS ana ekran widget jetonu köprüsü (3 Kas 2026).
// Web (Ravza) girişliyken /api/user/widget-jeton'dan aldığı jetonu buraya verir; jeton ORTAK anahtar zincirine
// (TeamID.com.ibrahimaktas.ravza.paylasim) yazılır, RavzaWidgets eklentisi aynı gruptan okur. App Group gerekmez.
import Foundation
import Capacitor
import Security
import WidgetKit

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
}

/// Capacitor 6: yerel eklentiyi köprüye kaydeder (storyboard bu sınıfı kullanır).
class RavzaKopruVC: CAPBridgeViewController {
    override open func capacitorDidLoad() {
        bridge?.registerPluginInstance(RavzaWidgetJeton())
    }
}
