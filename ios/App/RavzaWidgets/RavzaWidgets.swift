// Ravza iOS WidgetKit eklentisi (3 Kas 2026). Android 18 widget'ın iOS karşılığı, 1. aşama: girişsiz veri.
// Veri: /api/namaz-vakitleri (vakit + hicrî) ve /api/user/widget-ozet (âyet, esmâ, kandil, kampanya toplamı).
// Kişisel widget'lar (namaz takibi, hatim, ezkâr) App Group ile oturum paylaşımı gelince 2. aşamada.
// Tasarım: Android ile aynı marka (zümrüt #17463A/#0F3029/#0A1F1A, altın #E0C06A/#f3cf7a, krem #f4ecdc).
import WidgetKit
import SwiftUI

// MARK: - Renk ve yardımcılar
extension Color {
    static let rzZ1 = Color(red: 0x17/255, green: 0x46/255, blue: 0x3A/255)
    static let rzZ2 = Color(red: 0x0F/255, green: 0x30/255, blue: 0x29/255)
    static let rzZ3 = Color(red: 0x0A/255, green: 0x1F/255, blue: 0x1A/255)
    static let rzAltin = Color(red: 0xE0/255, green: 0xC0/255, blue: 0x6A/255)
    static let rzAltinP = Color(red: 0xF3/255, green: 0xCF/255, blue: 0x7A/255)
    static let rzAltinK = Color(red: 0xB4/255, green: 0x8C/255, blue: 0x3A/255)
    static let rzKrem = Color(red: 0xF4/255, green: 0xEC/255, blue: 0xDC/255)
    static let rzPetrol = Color(red: 0x2C/255, green: 0xA4/255, blue: 0xAB/255)
}

let rzAltinGrad = LinearGradient(colors: [Color(red: 1, green: 0.95, blue: 0.77), .rzAltin, .rzAltinK], startPoint: .top, endPoint: .bottom)
let rzZeminGrad = LinearGradient(colors: [.rzZ1, .rzZ2, .rzZ3], startPoint: .topLeading, endPoint: .bottomTrailing)
let SITE = "https://tesbihat.ibrahimaktas.com"

/// Girih deseni (8 köşeli yıldız ızgarası), çok hafif altın.
struct Girih: View {
    var body: some View {
        Canvas { ctx, size in
            let a: CGFloat = 26
            var y: CGFloat = 0
            while y < size.height + a {
                var x: CGFloat = 0
                while x < size.width + a {
                    var p = Path()
                    for i in 0..<8 {
                        let t = Double(i) * .pi / 4
                        let r: CGFloat = i % 2 == 0 ? 8 : 3.4
                        let pt = CGPoint(x: x + r * CGFloat(cos(t)), y: y + r * CGFloat(sin(t)))
                        if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
                    }
                    p.closeSubpath()
                    ctx.stroke(p, with: .color(Color.rzAltin.opacity(0.07)), lineWidth: 0.7)
                    x += a
                }
                y += a
            }
        }
    }
}

struct RzZemin: ViewModifier {
    @ViewBuilder func body(content: Content) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            content.containerBackground(for: .widget) { ZStack { rzZeminGrad; Girih() } }
        } else {
            content.padding(14).background(ZStack { rzZeminGrad; Girih() })
        }
    }
}
extension View { func rzZemin() -> some View { modifier(RzZemin()) } }

struct RzUst: View {
    let baslik: String
    var sag: String = ""
    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(rzAltinGrad).frame(width: 9, height: 9)
            Text(baslik).font(.system(size: 11, weight: .semibold)).foregroundColor(.rzAltin).lineLimit(1)
            Spacer(minLength: 4)
            Text(sag).font(.system(size: 10)).foregroundColor(.rzKrem.opacity(0.6)).lineLimit(1)
        }
    }
}

// MARK: - 11 dil
let DIL: String = {
    let d = String((Locale.preferredLanguages.first ?? "tr").prefix(2))
    return ["tr", "en", "ar", "de", "fr", "it", "nl", "ru", "ku", "ja", "zh"].contains(d) ? d : "en"
}()
let DILLER = ["tr", "en", "ar", "de", "fr", "it", "nl", "ru", "ku", "ja", "zh"]
let SOZ: [String: [String]] = [
    "imsak": ["İmsak", "Fajr", "الفجر", "Fadschr", "Fajr", "Fajr", "Fajr", "Фаджр", "Spêde", "ファジュル", "晨礼"],
    "gunes": ["Güneş", "Sunrise", "الشروق", "Sonnenaufgang", "Lever", "Alba", "Zonsopgang", "Восход", "Roj", "日の出", "日出"],
    "ogle": ["Öğle", "Dhuhr", "الظهر", "Dhuhr", "Dhuhr", "Dhuhr", "Dhuhr", "Зухр", "Nîvro", "ズフル", "晌礼"],
    "ikindi": ["İkindi", "Asr", "العصر", "Asr", "Asr", "Asr", "Asr", "Аср", "Êvar", "アスル", "晡礼"],
    "aksam": ["Akşam", "Maghrib", "المغرب", "Maghrib", "Maghrib", "Maghrib", "Maghrib", "Магриб", "Mexrib", "マグリブ", "昏礼"],
    "yatsi": ["Yatsı", "Isha", "العشاء", "Ischa", "Isha", "Isha", "Isha", "Иша", "Îşa", "イシャー", "宵礼"],
    "kaldi": ["kaldı", "left", "متبقٍ", "übrig", "restant", "mancano", "resterend", "осталось", "maye", "あと", "剩余"],
    "ayet": ["Günün Âyeti", "Verse of the Day", "آية اليوم", "Vers des Tages", "Verset du jour", "Versetto del giorno", "Vers van de dag", "Аят дня", "Ayeta rojê", "今日の一節", "今日经文"],
    "esma": ["Günün Esmâsı", "Divine Name", "اسم اليوم", "Gottesname", "Nom divin", "Nome divino", "Naam van Allah", "Имя Аллаха", "Navê Xwedê", "今日の御名", "今日尊名"],
    "hicri": ["Hicrî", "Hijri", "هجري", "Hidschri", "Hégire", "Egira", "Hidjri", "Хиджри", "Koçî", "ヒジュラ暦", "伊历"],
    "bugun": ["Bugün", "Today", "اليوم", "Heute", "Aujourd'hui", "Oggi", "Vandaag", "Сегодня", "Îro", "今日", "今天"],
    "gun_kaldi": ["%d gün kaldı", "%d days left", "بعد %d يومًا", "noch %d Tage", "dans %d jours", "tra %d giorni", "nog %d dagen", "через %d дн.", "%d roj mane", "あと%d日", "还有%d天"],
    "cuma": ["Cuma", "Friday", "الجمعة", "Freitag", "Vendredi", "Venerdì", "Vrijdag", "Пятница", "În", "金曜日", "主麻日"],
    "cuma_namazina": ["Cuma namazına", "To Friday prayer", "حتى صلاة الجمعة", "Bis zum Freitagsgebet", "Jusqu'à la prière du vendredi", "Alla preghiera del venerdì", "Tot het vrijdaggebed", "До пятничного намаза", "Heta nimêja înê", "金曜礼拝まで", "距主麻礼拜"],
    "gun_n": ["%d gün", "%d days", "%d يوم", "%d Tage", "%d jours", "%d giorni", "%d dagen", "%d дн.", "%d roj", "%d日", "%d天"],
    "bugun_cuma": ["Bugün Cuma", "Today is Friday", "اليوم الجمعة", "Heute ist Freitag", "C'est vendredi", "Oggi è venerdì", "Vandaag is het vrijdag", "Сегодня пятница", "Îro în e", "今日は金曜日", "今天是主麻日"],
    "cuma_sunnet": ["Kehf · Salâvat · Gusül", "Al-Kahf · Salawat · Ghusl", "الكهف · الصلاة على النبي · الغسل", "Al-Kahf · Salawat · Ghusl", "Al-Kahf · Salawat · Ghusl", "Al-Kahf · Salawat · Ghusl", "Al-Kahf · Salawat · Ghusl", "Аль-Кахф · Салават · Гусль", "Kehf · Selawat · Xusl", "カフフ章・サラワート・グスル", "山洞章 · 赞圣 · 大净"],
    "kampanya": ["Kampanya", "Campaign", "الحملة", "Kampagne", "Campagne", "Campagna", "Campagne", "Кампания", "Kampanya", "キャンペーン", "活动"],
    "ummet": ["Ümmetin toplamı", "Ummah total", "مجموع الأمة", "Umma gesamt", "Total de l'Oumma", "Totale Umma", "Totaal oemma", "Всего у уммы", "Giştiya ummetê", "ウンマ合計", "全体总计"],
    "katil": ["Dokun, katıl", "Tap to join", "اضغط للمشاركة", "Tippen, mitmachen", "Touchez pour participer", "Tocca per partecipare", "Tik om mee te doen", "Нажмите, чтобы участвовать", "Bitikîne, beşdar bibe", "タップして参加", "点击参与"],
    "oruc": ["Oruç vakti", "Fasting times", "أوقات الصيام", "Fastenzeiten", "Horaires du jeûne", "Orari del digiuno", "Vastentijden", "Время поста", "Demên rojiyê", "断食時間", "斋戒时间"],
    "iftar": ["İftar", "Iftar", "الإفطار", "Iftar", "Iftar", "Iftar", "Iftar", "Ифтар", "Fitar", "イフタール", "开斋"],
    "iftara": ["İftara", "To iftar", "حتى الإفطار", "Bis Iftar", "Jusqu'à l'iftar", "All'iftar", "Tot iftar", "До ифтара", "Heta fitarê", "イフタールまで", "距开斋"],
    "imsaka": ["İmsaka", "To imsak", "حتى الإمساك", "Bis Imsak", "Jusqu'à l'imsak", "All'imsak", "Tot imsak", "До имсака", "Heta imsakê", "イムサークまで", "距封斋"],
    "vakit": ["Namaz Vakti", "Prayer Times", "مواقيت الصلاة", "Gebetszeiten", "Heures de prière", "Orari di preghiera", "Gebedstijden", "Время намаза", "Demên nimêjê", "礼拝時刻", "礼拜时间"],
    "vakit_ac": ["Sıradaki vakit ve canlı geri sayım", "Next prayer with live countdown", "الصلاة التالية مع العد التنازلي", "Nächstes Gebet mit Countdown", "Prochaine prière avec compte à rebours", "Prossima preghiera con conto alla rovescia", "Volgend gebed met aftelling", "Следующий намаз с отсчётом", "Nimêja din pê û jimartin", "次の礼拝とカウントダウン", "下次礼拜与倒计时"],
    "ayet_ac": ["Her gün bir âyet ve meali", "A verse and its meaning every day", "آية ومعناها كل يوم", "Täglich ein Vers mit Bedeutung", "Un verset et son sens chaque jour", "Un versetto e il suo significato ogni giorno", "Elke dag een vers met betekenis", "Аят и смысл каждый день", "Her roj ayetek û wateya wê", "毎日の一節と意味", "每日一节经文及释义"],
    "esma_ac": ["Esmâ-ül Hüsnâ'dan bir isim", "A Beautiful Name of Allah", "اسم من الأسماء الحسنى", "Ein schöner Name Allahs", "Un beau nom d'Allah", "Un bel nome di Allah", "Een schone naam van Allah", "Прекрасное имя Аллаха", "Navekî xweş ê Xwedê", "アッラーの美名", "安拉的尊名"],
    "hicri_ac": ["Hicrî tarih ve yaklaşan kandil", "Hijri date and the next blessed night", "التاريخ الهجري والليلة المباركة", "Hidschri-Datum und gesegnete Nacht", "Date hégirienne et nuit bénie", "Data dell'Egira e notte benedetta", "Hidjri-datum en gezegende nacht", "Дата хиджры и благословенная ночь", "Dîroka koçî û şeva pîroz", "ヒジュラ暦と祝福の夜", "伊历日期与吉夜"],
    "cuma_ac": ["Cumaya kalan gün ve sünnetleri", "Days to Friday and its sunnahs", "الأيام حتى الجمعة وسننها", "Tage bis Freitag und Sunna", "Jours avant vendredi et sunnas", "Giorni al venerdì e sunna", "Dagen tot vrijdag en soenna's", "Дни до пятницы и сунны", "Rojên heta înê û sunnet", "金曜日までとスンナ", "距主麻日与圣行"],
    "kampanya_ac": ["Ümmetin zikir kampanyası", "The Ummah's dhikr campaign", "حملة الذكر للأمة", "Dhikr-Kampagne der Umma", "Campagne de dhikr de l'Oumma", "Campagna di dhikr dell'Umma", "Dhikr-campagne van de oemma", "Кампания зикра уммы", "Kampanyaya zikirê", "ウンマのズィクル", "全体赞念活动"],
    "oruc_ac": ["İmsaktan iftara güneş yayı", "Sun arc from imsak to iftar", "قوس الشمس من الإمساك إلى الإفطار", "Sonnenbogen bis Iftar", "Arc solaire jusqu'à l'iftar", "Arco solare fino all'iftar", "Zonneboog tot iftar", "Дуга солнца до ифтара", "Kevana rojê heta fitarê", "イフタールまでの太陽の弧", "从封斋到开斋的日弧"],
    "kilit": ["Kilit ekranı vakti", "Lock screen prayer", "وقت شاشة القفل", "Sperrbildschirm-Gebet", "Prière écran verrouillé", "Preghiera schermata blocco", "Gebed op vergrendelscherm", "Намаз на экране блокировки", "Nimêja ekrana kilîtkirî", "ロック画面の礼拝", "锁屏礼拜"],
]
func L(_ k: String) -> String {
    guard let v = SOZ[k] else { return k }
    let i = DILLER.firstIndex(of: DIL) ?? 1
    return i < v.count ? v[i] : v[1]
}
func L(_ k: String, _ n: Int) -> String { String(format: L(k), n) }
let VAKIT_ANAHTAR = ["Fajr", "Sunrise", "Dhuhr", "Asr", "Maghrib", "Isha"]
let VAKIT_AD = ["imsak", "gunes", "ogle", "ikindi", "aksam", "yatsi"]
let VAKIT_AR = ["الفجر", "الشروق", "الظهر", "العصر", "المغرب", "العشاء"]
let HICRI_TR = ["Muharrem", "Safer", "Rebiülevvel", "Rebiülahir", "Cemaziyelevvel", "Cemaziyelahir", "Recep", "Şaban", "Ramazan", "Şevval", "Zilkade", "Zilhicce"]

func sayi(_ n: Int) -> String {
    let f = NumberFormatter(); f.numberStyle = .decimal
    f.locale = Locale(identifier: ["tr", "de", "it", "nl"].contains(DIL) ? "tr_TR" : "en_US")
    return f.string(from: NSNumber(value: n)) ?? "\(n)"
}

// MARK: - Veri
struct Vakitler {
    var saat: [Date] = []      // 6 vakit, bugün
    var yarinImsak: Date? = nil
    var hicriGun = "", hicriAy = "", hicriAyAr = "", hicriYil = "", hicriAyNo = 0
    var bos: Bool { saat.count < 6 }
    /// (sıradaki vakit indeksi, hedef zaman, önceki vakit zamanı)
    func siradaki(_ simdi: Date) -> (Int, Date, Date) {
        guard !bos else { return (0, simdi.addingTimeInterval(3600), simdi) }
        for i in 0..<6 where saat[i] > simdi {
            let onceki = i > 0 ? saat[i - 1] : saat[5].addingTimeInterval(-86400)
            return (i, saat[i], onceki)
        }
        let yi = yarinImsak ?? saat[0].addingTimeInterval(86400)
        return (0, yi, saat[5])
    }
}

struct Ozet {
    var ayetAr = "", ayetMeal = "", ayetKaynak = ""
    var hadis = "", hadisKaynak = ""
    var esmaAr = "", esmaAd = "", esmaAnlam = "", esmaAdet = 0
    var kandil = "", kandilGun = -1
    var kampId = "", kampBaslik = "", kampAr = "", kampToplam = 0, kampHedef = 0
}

enum Veri {
    static let paylasim = UserDefaults.standard
    static func cek(_ yol: String) async -> [String: Any]? {
        guard let u = URL(string: SITE + yol) else { return nil }
        var r = URLRequest(url: u, timeoutInterval: 12)
        r.setValue("application/json", forHTTPHeaderField: "Accept")
        r.setValue("RavzaWidget/2.0 iOS", forHTTPHeaderField: "User-Agent")
        do {
            let (d, y) = try await URLSession.shared.data(for: r)
            guard (y as? HTTPURLResponse)?.statusCode == 200 else { return onbellek(yol) }
            let j = try JSONSerialization.jsonObject(with: d) as? [String: Any]
            if let j = j { paylasim.set(d, forKey: "onbellek_" + yol) }
            return j
        } catch {
            // Çevrimdışı: son başarılı cevap
            return onbellek(yol)
        }
    }
    static func onbellek(_ yol: String) -> [String: Any]? {
        guard let d = paylasim.data(forKey: "onbellek_" + yol) else { return nil }
        return try? JSONSerialization.jsonObject(with: d) as? [String: Any]
    }

    static func vakitler() async -> Vakitler {
        var v = Vakitler()
        guard let j = await cek("/api/namaz-vakitleri"), let t = j["timings"] as? [String: Any] else { return v }
        let tak = Calendar.current
        let bugun = tak.startOfDay(for: Date())
        for k in VAKIT_ANAHTAR {
            let s = String(((t[k] as? String) ?? "00:00").prefix(5))
            let p = s.split(separator: ":").compactMap { Int($0) }
            if p.count == 2, let d = tak.date(bySettingHour: p[0], minute: p[1], second: 0, of: bugun) { v.saat.append(d) }
        }
        if v.saat.count == 6 { v.yarinImsak = v.saat[0].addingTimeInterval(86400) }
        if let h = (j["date"] as? [String: Any])?["hijri"] as? [String: Any] {
            v.hicriGun = "\(h["day"] ?? "")"
            v.hicriYil = "\(h["year"] ?? "")"
            if let ay = h["month"] as? [String: Any] {
                v.hicriAyNo = (ay["number"] as? Int) ?? 0
                v.hicriAyAr = (ay["ar"] as? String) ?? ""
                v.hicriAy = DIL == "tr" && (1...12).contains(v.hicriAyNo) ? HICRI_TR[v.hicriAyNo - 1] : (DIL == "ar" ? v.hicriAyAr : (ay["en"] as? String) ?? "")
            }
        }
        return v
    }

    static func ozet() async -> Ozet {
        var o = Ozet()
        guard let j = await cek("/api/user/widget-ozet?dil=" + DIL) else { return o }
        if let a = j["ayet"] as? [String: Any] { o.ayetAr = a["ar"] as? String ?? ""; o.ayetMeal = a["meal"] as? String ?? ""; o.ayetKaynak = a["kaynak"] as? String ?? "" }
        if let h = j["hadis"] as? [String: Any] { o.hadis = h["metin"] as? String ?? ""; o.hadisKaynak = h["kaynak"] as? String ?? "" }
        if let e = j["esma"] as? [String: Any] { o.esmaAr = e["ar"] as? String ?? ""; o.esmaAd = e["ad"] as? String ?? ""; o.esmaAnlam = e["anlam"] as? String ?? ""; o.esmaAdet = e["adet"] as? Int ?? 0 }
        if let m = j["mubarek"] as? [String: Any] { o.kandil = m["ad"] as? String ?? ""; o.kandilGun = m["kalan_gun"] as? Int ?? -1 }
        if let k = j["kampanya"] as? [String: Any] {
            o.kampId = k["id"] as? String ?? ""; o.kampBaslik = k["baslik"] as? String ?? ""; o.kampAr = k["arapca"] as? String ?? ""
            o.kampToplam = (k["toplam"] as? NSNumber)?.intValue ?? 0; o.kampHedef = (k["hedef"] as? NSNumber)?.intValue ?? 0
        }
        return o
    }
}

// MARK: - Zaman çizelgesi (tüm widget'lar ortak)
struct RzEntry: TimelineEntry {
    let date: Date
    let v: Vakitler
    let o: Ozet
}

struct RzProvider: TimelineProvider {
    func placeholder(in context: Context) -> RzEntry { RzEntry(date: Date(), v: ornekVakit(), o: ornekOzet()) }
    func getSnapshot(in context: Context, completion: @escaping (RzEntry) -> Void) {
        if context.isPreview { completion(placeholder(in: context)); return }
        Task { completion(RzEntry(date: Date(), v: await Veri.vakitler(), o: await Veri.ozet())) }
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<RzEntry>) -> Void) {
        Task {
            let v = await Veri.vakitler()
            let o = await Veri.ozet()
            let simdi = Date()
            // Her vakit girişinde yeni giriş: sıradaki vakit ve geri sayım hedefi değişir. Geri sayım Text(.timer) ile canlı.
            var girdiler = [RzEntry(date: simdi, v: v, o: o)]
            let gece = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: simdi))!.addingTimeInterval(90)
            let sonraki = min(gece, simdi.addingTimeInterval(v.bos ? 900 : 3 * 3600))
            var anlar = Set<Date>()
            var t = simdi.addingTimeInterval(600)
            while t < sonraki { anlar.insert(t); t = t.addingTimeInterval(600) }   // halka ve yay 10 dk'da bir ilerler
            for d in v.saat where d > simdi && d < sonraki { anlar.insert(d.addingTimeInterval(1)) }   // vakit girince sıradaki değişir
            for d in anlar.sorted() { girdiler.append(RzEntry(date: d, v: v, o: o)) }
            completion(Timeline(entries: girdiler, policy: .after(sonraki)))
        }
    }
    func ornekVakit() -> Vakitler {
        var v = Vakitler(); let b = Calendar.current.startOfDay(for: Date())
        v.saat = [6 * 60 + 4, 7 * 60 + 30, 12 * 60 + 53, 15 * 60 + 39, 18 * 60 + 6, 19 * 60 + 27].map { b.addingTimeInterval(Double($0) * 60) }
        v.yarinImsak = v.saat[0].addingTimeInterval(86400)
        v.hicriGun = "22"; v.hicriAy = DIL == "tr" ? "Cemaziyelevvel" : "Jumada al-Ula"; v.hicriAyAr = "جُمادى الأولى"; v.hicriYil = "1448"; v.hicriAyNo = 5
        return v
    }
    func ornekOzet() -> Ozet {
        var o = Ozet()
        o.ayetAr = "أَلَا بِذِكْرِ اللّٰهِ تَطْمَئِنُّ الْقُلُوبُ"; o.ayetMeal = DIL == "tr" ? "Bilesiniz ki kalpler ancak Allah'ı anmakla huzur bulur." : "Surely in the remembrance of Allah do hearts find rest."; o.ayetKaynak = "13:28"
        o.esmaAr = "الْمُحْيِي"; o.esmaAd = "El-Muhyî"; o.esmaAnlam = DIL == "tr" ? "Hayat veren" : "The Giver of Life"; o.esmaAdet = 68
        o.kandil = DIL == "tr" ? "Regaib Kandili" : "Raghaib Night"; o.kandilGun = 37
        o.kampBaslik = "10 Milyon La ilahe illallah"; o.kampAr = "لَا إِلٰهَ إِلَّا اللّٰهُ"; o.kampToplam = 1_171_947; o.kampHedef = 10_000_000
        return o
    }
}

// MARK: - 1 · Vakit paneli (küçük + orta)
struct VakitPanelView: View {
    @Environment(\.widgetFamily) var aile
    let e: RzEntry
    var body: some View {
        let (i, hedef, _) = e.v.siradaki(e.date)
        VStack(alignment: .leading, spacing: 4) {
            RzUst(baslik: "Ravza", sag: aile == .systemSmall ? "" : "\(e.v.hicriGun) \(e.v.hicriAy) \(e.v.hicriYil)")
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(L(VAKIT_AD[i])).font(.system(size: aile == .systemSmall ? 14 : 16, weight: .bold, design: .serif)).foregroundColor(.rzAltin)
                if aile != .systemSmall { Text(VAKIT_AR[i]).font(.system(size: 14)).foregroundColor(.rzKrem.opacity(0.7)) }
            }
            Text(hedef, style: .timer)
                .font(.system(size: aile == .systemSmall ? 28 : 34, weight: .bold, design: .rounded).monospacedDigit())
                .foregroundStyle(rzAltinGrad).lineLimit(1).minimumScaleFactor(0.6)
            Text("\(L(VAKIT_AD[i])) \(saatYaz(hedef)) · \(L("kaldi"))").font(.system(size: 10)).foregroundColor(.rzKrem.opacity(0.65))
            if aile != .systemSmall && !e.v.bos {
                Spacer(minLength: 2)
                HStack(spacing: 2) {
                    ForEach(0..<6, id: \.self) { k in
                        VStack(spacing: 1) {
                            Text(L(VAKIT_AD[k])).font(.system(size: 8.5)).foregroundColor(k == i ? .rzAltinP : .rzKrem.opacity(0.6)).lineLimit(1).minimumScaleFactor(0.7)
                            Text(saatYaz(e.v.saat[k])).font(.system(size: 12, weight: .bold).monospacedDigit()).foregroundColor(k == i ? .rzAltinP : .rzKrem)
                        }
                        .frame(maxWidth: .infinity).padding(.vertical, 3)
                        .background(RoundedRectangle(cornerRadius: 8).fill(k == i ? Color.rzAltin.opacity(0.18) : .clear))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(k == i ? Color.rzAltin.opacity(0.5) : .clear, lineWidth: 0.8))
                    }
                }
            } else { Spacer(minLength: 0) }
        }
        .rzZemin()
        .widgetURL(URL(string: SITE + "/namaz-vakitleri"))
    }
}
func saatYaz(_ d: Date) -> String { let f = DateFormatter(); f.dateFormat = "HH:mm"; return f.string(from: d) }

struct VakitPanel: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "RavzaVakitPanel", provider: RzProvider()) { VakitPanelView(e: $0) }
            .configurationDisplayName(L("vakit")).description(L("vakit_ac"))
            .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - 2 · Vakit halkası + kilit ekranı (dairesel, dikdörtgen, satır)
struct HalkaView: View {
    @Environment(\.widgetFamily) var aile
    let e: RzEntry
    var body: some View {
        let (i, hedef, onceki) = e.v.siradaki(e.date)
        switch aile {
        case .accessoryCircular:
            Gauge(value: max(0, min(1, e.date.timeIntervalSince(onceki) / max(1, hedef.timeIntervalSince(onceki))))) {
                Text(String(L(VAKIT_AD[i]).prefix(3)))
            } currentValueLabel: { Text(saatYaz(hedef)).font(.system(size: 11, weight: .semibold)) }
            .gaugeStyle(.accessoryCircular)
            .widgetURL(URL(string: SITE + "/namaz-vakitleri"))
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 1) {
                Text("\(L(VAKIT_AD[i])) \(saatYaz(hedef))").font(.system(size: 15, weight: .bold))
                Text(hedef, style: .timer).font(.system(size: 13).monospacedDigit())
                ProgressView(timerInterval: onceki...hedef, countsDown: false) { EmptyView() } currentValueLabel: { EmptyView() }
            }
            .widgetURL(URL(string: SITE + "/namaz-vakitleri"))
        case .accessoryInline:
            Text("\(L(VAKIT_AD[i])) \(saatYaz(hedef))")
        default:
            ZStack {
                Halka(oran: max(0, min(1, e.date.timeIntervalSince(onceki) / max(1, hedef.timeIntervalSince(onceki)))))
                VStack(spacing: 1) {
                    Text(L(VAKIT_AD[i])).font(.system(size: 13, weight: .bold, design: .serif)).foregroundColor(.rzAltin)
                    Text(hedef, style: .timer).font(.system(size: 18, weight: .bold, design: .rounded).monospacedDigit()).foregroundStyle(rzAltinGrad)
                        .multilineTextAlignment(.center).lineLimit(1).minimumScaleFactor(0.6).frame(maxWidth: 84)
                    Text(saatYaz(hedef)).font(.system(size: 10)).foregroundColor(.rzKrem.opacity(0.65))
                }
            }
            .padding(4)
            .rzZemin()
            .widgetURL(URL(string: SITE + "/namaz-vakitleri"))
        }
    }
}
/// Petrol→altın gradyan halka (giriş anındaki oran, 10 dk'da bir yenilenir).
struct Halka: View {
    let oran: Double
    var body: some View {
        let f = oran
        ZStack {
            Circle().stroke(Color.rzKrem.opacity(0.12), lineWidth: 8)
            Circle().trim(from: 0, to: f)
                .stroke(AngularGradient(colors: [.rzPetrol, .rzAltinP], center: .center), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}
struct VakitHalka: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "RavzaVakitHalka", provider: RzProvider()) { HalkaView(e: $0) }
            .configurationDisplayName(L("vakit")).description(L("kilit"))
            .supportedFamilies([.systemSmall, .accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

// MARK: - 4 · Günün âyeti
struct AyetView: View {
    @Environment(\.widgetFamily) var aile
    let e: RzEntry
    var body: some View {
        let hadis = e.o.ayetMeal.isEmpty
        VStack(spacing: 6) {
            RzUst(baslik: L("ayet"), sag: tarihKisa(e.date))
            Spacer(minLength: 0)
            if !hadis {
                Text(e.o.ayetAr).font(.system(size: aile == .systemLarge ? 26 : 20)).foregroundStyle(rzAltinGrad)
                    .multilineTextAlignment(.center).lineLimit(aile == .systemLarge ? 4 : 2).minimumScaleFactor(0.7)
                Rectangle().fill(LinearGradient(colors: [.clear, .rzAltin, .clear], startPoint: .leading, endPoint: .trailing)).frame(width: 140, height: 0.8)
                Text("“\(e.o.ayetMeal)”").font(.system(size: 13, design: .serif).italic()).foregroundColor(.rzKrem)
                    .multilineTextAlignment(.center).lineLimit(aile == .systemLarge ? 8 : 3).minimumScaleFactor(0.75)
                Text(e.o.ayetKaynak.uppercased()).font(.system(size: 9.5, weight: .bold)).tracking(0.6).foregroundColor(.rzAltin)
            } else {
                Text("“\(e.o.hadis)”").font(.system(size: 13, design: .serif)).foregroundColor(.rzKrem).multilineTextAlignment(.center).lineLimit(6)
                Text(e.o.hadisKaynak).font(.system(size: 9.5, weight: .bold)).foregroundColor(.rzAltin)
            }
            Spacer(minLength: 0)
        }
        .rzZemin()
        .widgetURL(URL(string: SITE + "/kuran"))
    }
}
func tarihKisa(_ d: Date) -> String { let f = DateFormatter(); f.locale = Locale(identifier: DIL); f.setLocalizedDateFormatFromTemplate("d MMMM"); return f.string(from: d) }
struct Ayet: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "RavzaAyet", provider: RzProvider()) { AyetView(e: $0) }
            .configurationDisplayName(L("ayet")).description(L("ayet_ac"))
            .supportedFamilies([.systemMedium, .systemLarge])
    }
}

// MARK: - 14 · Günün esmâsı
struct EsmaView: View {
    let e: RzEntry
    var body: some View {
        VStack(spacing: 3) {
            RzUst(baslik: L("esma"))
            Spacer(minLength: 0)
            Text(e.o.esmaAr).font(.system(size: 30)).foregroundStyle(rzAltinGrad).lineLimit(1).minimumScaleFactor(0.6)
            Text(e.o.esmaAd).font(.system(size: 14, weight: .semibold, design: .serif)).foregroundColor(.rzAltin)
            Text(e.o.esmaAnlam).font(.system(size: 10)).foregroundColor(.rzKrem.opacity(0.7)).multilineTextAlignment(.center).lineLimit(2)
            if e.o.esmaAdet > 0 {
                Text(sayi(e.o.esmaAdet) + "×").font(.system(size: 10, weight: .bold)).foregroundColor(.rzAltinP)
                    .padding(.horizontal, 10).padding(.vertical, 2).background(Capsule().fill(Color.rzAltin.opacity(0.16)))
            }
            Spacer(minLength: 0)
        }
        .rzZemin()
        .widgetURL(URL(string: SITE + "/esma"))
    }
}
struct Esma: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "RavzaEsma", provider: RzProvider()) { EsmaView(e: $0) }
            .configurationDisplayName(L("esma")).description(L("esma_ac")).supportedFamilies([.systemSmall])
    }
}

// MARK: - 5 · Hicrî takvim + kandil
struct HicriView: View {
    let e: RzEntry
    var body: some View {
        VStack(spacing: 2) {
            RzUst(baslik: L("hicri"), sag: e.v.hicriYil)
            Spacer(minLength: 0)
            Text(e.v.hicriGun.isEmpty ? "—" : e.v.hicriGun).font(.system(size: 44, weight: .bold, design: .serif)).foregroundStyle(rzAltinGrad)
            Text(e.v.hicriAyAr).font(.system(size: 14)).foregroundColor(.rzAltin)
            Text(e.v.hicriAy).font(.system(size: 10)).foregroundColor(.rzKrem.opacity(0.7))
            Spacer(minLength: 0)
            if !e.o.kandil.isEmpty {
                VStack(spacing: 0) {
                    Text(e.o.kandil).font(.system(size: 9.5)).foregroundColor(.rzKrem).lineLimit(1).minimumScaleFactor(0.7)
                    Text(e.o.kandilGun == 0 ? L("bugun") : L("gun_kaldi", e.o.kandilGun)).font(.system(size: 11, weight: .bold)).foregroundColor(.rzAltinP)
                }
                .frame(maxWidth: .infinity).padding(.vertical, 4)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.rzAltin.opacity(0.13)))
            }
        }
        .rzZemin()
        .widgetURL(URL(string: SITE + "/takvim"))
    }
}
struct Hicri: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "RavzaHicri", provider: RzProvider()) { HicriView(e: $0) }
            .configurationDisplayName(L("hicri")).description(L("hicri_ac")).supportedFamilies([.systemSmall])
    }
}

// MARK: - 12 · Cuma
struct CumaView: View {
    let e: RzEntry
    var body: some View {
        let hg = Calendar.current.component(.weekday, from: e.date) // 6 = Cuma
        let kalan = (6 - hg + 7) % 7
        VStack(spacing: 3) {
            RzUst(baslik: L("cuma"), sag: kalan == 0 ? "" : L("cuma_namazina"))
            Spacer(minLength: 0)
            Text(kalan == 0 ? L("bugun_cuma") : L("gun_n", kalan)).font(.system(size: kalan == 0 ? 20 : 30, weight: .bold, design: .serif))
                .foregroundStyle(rzAltinGrad).lineLimit(1).minimumScaleFactor(0.6)
            Spacer(minLength: 0)
            Text(L("cuma_sunnet")).font(.system(size: 9.5)).foregroundColor(.rzKrem).multilineTextAlignment(.center).lineLimit(2)
                .frame(maxWidth: .infinity).padding(6)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.rzAltin.opacity(0.12)))
        }
        .rzZemin()
        .widgetURL(URL(string: SITE + "/takvim"))
    }
}
struct Cuma: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "RavzaCuma", provider: RzProvider()) { CumaView(e: $0) }
            .configurationDisplayName(L("cuma")).description(L("cuma_ac")).supportedFamilies([.systemSmall])
    }
}

// MARK: - 9 · Kampanya (ümmetin toplamı, dokununca kampanya sayfası)
struct KampanyaView: View {
    let e: RzEntry
    var body: some View {
        let oran = e.o.kampHedef > 0 ? min(1, Double(e.o.kampToplam) / Double(e.o.kampHedef)) : 0
        VStack(alignment: .leading, spacing: 4) {
            RzUst(baslik: L("kampanya"), sag: e.o.kampBaslik)
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(L("ummet")).font(.system(size: 10)).foregroundColor(.rzKrem.opacity(0.65))
                    Text(sayi(e.o.kampToplam)).font(.system(size: 26, weight: .bold, design: .rounded).monospacedDigit()).foregroundStyle(rzAltinGrad)
                        .lineLimit(1).minimumScaleFactor(0.6)
                    Text("/ " + sayi(e.o.kampHedef)).font(.system(size: 11)).foregroundColor(.rzKrem.opacity(0.65))
                }
                Spacer()
                Text(e.o.kampAr).font(.system(size: 20)).foregroundStyle(rzAltinGrad).lineLimit(1).minimumScaleFactor(0.6)
            }
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.rzKrem.opacity(0.12))
                    Capsule().fill(LinearGradient(colors: [.rzPetrol, .rzAltinP], startPoint: .leading, endPoint: .trailing)).frame(width: max(6, g.size.width * oran))
                }
            }.frame(height: 6)
            HStack {
                Text(String(format: "%%%.1f", oran * 100)).font(.system(size: 10, weight: .bold)).foregroundColor(.rzAltinP)
                Spacer()
                Text(L("katil")).font(.system(size: 10, weight: .bold)).foregroundColor(Color(red: 0.1, green: 0.07, blue: 0.02))
                    .padding(.horizontal, 10).padding(.vertical, 3).background(Capsule().fill(rzAltinGrad))
            }
        }
        .rzZemin()
        .widgetURL(URL(string: SITE + "/kampanya"))
    }
}
struct Kampanya: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "RavzaKampanya", provider: RzProvider()) { KampanyaView(e: $0) }
            .configurationDisplayName(L("kampanya")).description(L("kampanya_ac")).supportedFamilies([.systemMedium])
    }
}

// MARK: - 7 · Oruç / iftar
struct OrucView: View {
    let e: RzEntry
    var body: some View {
        let v = e.v
        let imsak = v.bos ? e.date : v.saat[0], iftar = v.bos ? e.date : v.saat[4]
        let gunduz = e.date >= imsak && e.date < iftar
        let hedef = gunduz ? iftar : (e.date < imsak ? imsak : (v.yarinImsak ?? imsak))
        VStack(alignment: .leading, spacing: 4) {
            RzUst(baslik: v.hicriAyNo == 9 ? "Ramazan · \(v.hicriGun)" : L("oruc"))
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(L("imsak")).font(.system(size: 10)).foregroundColor(.rzKrem.opacity(0.65))
                    Text(v.bos ? "--:--" : saatYaz(imsak)).font(.system(size: 18, weight: .bold).monospacedDigit()).foregroundColor(.rzKrem)
                }
                Spacer()
                VStack(spacing: 0) {
                    Text(gunduz ? L("iftara") : L("imsaka")).font(.system(size: 10)).foregroundColor(.rzKrem.opacity(0.65))
                    Text(hedef, style: .timer).font(.system(size: 22, weight: .bold, design: .rounded).monospacedDigit()).foregroundStyle(rzAltinGrad)
                        .multilineTextAlignment(.center).lineLimit(1).minimumScaleFactor(0.6)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 0) {
                    Text(L("iftar")).font(.system(size: 10)).foregroundColor(.rzKrem.opacity(0.65))
                    Text(v.bos ? "--:--" : saatYaz(iftar)).font(.system(size: 18, weight: .bold).monospacedDigit()).foregroundColor(.rzKrem)
                }
            }
            if gunduz {
                ProgressView(timerInterval: imsak...iftar, countsDown: false) { EmptyView() } currentValueLabel: { EmptyView() }.tint(.rzAltin)
            } else {
                Capsule().fill(Color.rzKrem.opacity(0.12)).frame(height: 4)
            }
        }
        .rzZemin()
        .widgetURL(URL(string: SITE + "/ramazan"))
    }
}
struct Oruc: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "RavzaOruc", provider: RzProvider()) { OrucView(e: $0) }
            .configurationDisplayName(L("oruc")).description(L("oruc_ac")).supportedFamilies([.systemMedium])
    }
}

// MARK: - Paket
@main
struct RavzaWidgetPaketi: WidgetBundle {
    var body: some Widget {
        VakitPanel()
        VakitHalka()
        Ayet()
        Esma()
        Hicri()
        Cuma()
        Kampanya()
        Oruc()
    }
}
