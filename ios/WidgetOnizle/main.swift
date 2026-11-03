// Widget önizleme: RavzaWidgets.swift görünümlerini macOS'ta değil, iOS simülatöründe değil,
// doğrudan macOS SwiftUI ImageRenderer ile PNG'ye çizer (CI kontrolü, mağaza dışı).
import SwiftUI
import WidgetKit
import AppKit

@MainActor func ciz<V: View>(_ v: V, _ w: CGFloat, _ h: CGFloat, _ ad: String) {
    let kap = v.frame(width: w - 32, height: h - 32).padding(16).background(ZStack { rzZeminGrad; Girih() }).frame(width: w, height: h).clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .padding(12).background(Color(white: 0.12))
    let r = ImageRenderer(content: kap); r.scale = 2
    guard let ns = r.nsImage, let t = ns.tiffRepresentation, let b = NSBitmapImageRep(data: t), let png = b.representation(using: .png, properties: [:]) else { print("HATA", ad); return }
    try! png.write(to: URL(fileURLWithPath: "cikti/\(ad).png")); print("OK", ad)
}
@MainActor func calis() {
    let p = RzProvider()
    var oz = p.ornekOzet(); oz.giris = true; oz.kilinan = ["Fajr", "Dhuhr"]; oz.seri = 12; oz.zikirBugun = 640; oz.zikirHedef = 1000; oz.sabah = true
    oz.hatimAd = "Ramazan Hatmi"; oz.hatimToplam = 30; oz.hatimBiten = 17
    let e = RzEntry(date: Date(), v: p.ornekVakit(), o: oz)
    ciz(VakitPanelView(aile: .systemSmall, e: e), 158, 158, "1_vakit_kucuk")
    ciz(VakitPanelView(aile: .systemMedium, e: e), 338, 158, "2_vakit_orta")
    ciz(HalkaView(aile: .systemSmall, e: e), 158, 158, "3_halka")
    ciz(AyetView(aile: .systemMedium, e: e), 338, 158, "4_ayet_orta")
    ciz(AyetView(aile: .systemLarge, e: e), 338, 354, "5_ayet_buyuk")
    ciz(EsmaView(e: e), 158, 158, "6_esma")
    ciz(HicriView(e: e), 158, 158, "7_hicri")
    ciz(CumaView(e: e), 158, 158, "8_cuma")
    ciz(KampanyaView(e: e), 338, 158, "9_kampanya")
    ciz(OrucView(e: e), 338, 158, "10_oruc")
    ciz(NamazTakipView(e: e), 338, 158, "11_namaz")
    ciz(HedeflerView(e: e), 338, 158, "12_hedefler")
    ciz(HatimView(e: e), 158, 158, "13_hatim")
}
try? FileManager.default.createDirectory(atPath: "cikti", withIntermediateDirectories: true)
MainActor.assumeIsolated { calis() }
