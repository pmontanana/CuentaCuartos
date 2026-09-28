import SwiftUI
import WatchConnectivity
import Combine

class WatchDataReceiver: NSObject, ObservableObject, WCSessionDelegate {
    @Published var dashboardData: WatchDashboardData?
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            // Leer los últimos datos guardados si los hay
            self.processContext(session.receivedApplicationContext)
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        self.processContext(applicationContext)
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        self.processContext(userInfo)
    }
    
    private func processContext(_ context: [String: Any]) {
        if let encoded = context["dashboardData"] as? Data {
            if let decoded = try? JSONDecoder().decode(WatchDashboardData.self, from: encoded) {
                DispatchQueue.main.async {
                    self.dashboardData = decoded
                }
            }
        }
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
    #endif
}

@main
struct CuentaCuartosWatch_Watch_AppApp: App {
    @StateObject private var receiver = WatchDataReceiver()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(receiver)
        }
    }
}
