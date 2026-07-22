// Ravza Apple Watch App — MVP (SwiftUI + WatchConnectivity)
// Tek buton: her dokunusta telefona "dhikr +1" gonderir.
import SwiftUI
import WatchConnectivity

class RavzaWatchSession: NSObject, ObservableObject, WCSessionDelegate {
    @Published var sessionCount: Int = 0
    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    func sendDhikr() {
        sessionCount += 1
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["dhikr": 1], replyHandler: nil, errorHandler: nil)
        } else {
            // ulasilamiyorsa context ile en son toplami senkronize et
            try? WCSession.default.updateApplicationContext(["pendingDhikr": sessionCount])
        }
    }
    func session(_ s: WCSession, activationDidCompleteWith st: WCSessionActivationState, error: Error?) {}
}

struct ContentView: View {
    @StateObject var s = RavzaWatchSession()
    var body: some View {
        VStack(spacing: 12) {
            Text("رَوْضَة").font(.title2).foregroundColor(Color(red:0.89,green:0.77,blue:0.35))
            Text("\(s.sessionCount)").font(.system(size: 44, weight: .bold))
            Button(action: { s.sendDhikr() }) {
                Text("Zikir Çek").font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(red:0.05,green:0.42,blue:0.35))
        }
        .padding()
    }
}

@main
struct RavzaWatchApp: App {
    var body: some Scene { WindowGroup { ContentView() } }
}
