import Foundation
#if canImport(WatchConnectivity)
import WatchConnectivity
#endif
import Combine

#if canImport(WatchConnectivity)
class WatchSyncManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchSyncManager()
    
    private var lastTransactions: [FinancialTransaction] = []
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func syncDashboard(transactions: [FinancialTransaction]) {
        self.lastTransactions = transactions
        sendDataIfPossible()
    }
    
    private func sendDataIfPossible() {
        guard WCSession.default.activationState == .activated else { return }
        
        let transactions = self.lastTransactions
        let totalIncome = transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        let totalExpenses = transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        let totalBalance = totalIncome - totalExpenses
        
        // Coger los últimos 7 días
        var recentIncomes = [Double](repeating: 0, count: 7)
        var recentExpenses = [Double](repeating: 0, count: 7)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        for t in transactions {
            let tDay = calendar.startOfDay(for: t.date)
            if let daysAgo = calendar.dateComponents([.day], from: tDay, to: today).day, daysAgo >= 0 && daysAgo < 7 {
                if t.type == .income {
                    recentIncomes[6 - daysAgo] += t.amount
                } else {
                    recentExpenses[6 - daysAgo] += t.amount
                }
            }
        }
        
        // Últimas 5 transacciones
        let recentTrans = transactions.prefix(5).map { t in
            WatchTransaction(
                id: t.id ?? UUID().uuidString,
                amount: t.amount,
                type: t.type.rawValue,
                date: t.date,
                categorySymbol: t.categorySymbol ?? "doc.text",
                categoryHexColor: t.categoryHexColor ?? "#CCCCCC"
            )
        }
        
        let data = WatchDashboardData(
            totalBalance: totalBalance,
            totalIncome: totalIncome,
            totalExpenses: totalExpenses,
            recentIncomes: recentIncomes,
            recentExpenses: recentExpenses,
            recentTransactions: recentTrans
        )
        
        do {
            let encoded = try JSONEncoder().encode(data)
            try WCSession.default.updateApplicationContext(["dashboardData": encoded])
            WCSession.default.transferUserInfo(["dashboardData": encoded]) // Doble seguro para envío inmediato
        } catch {
            print("Error encoding WatchData: \(error)")
        }
    }
    
    // MARK: - WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            sendDataIfPossible()
        }
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    #endif
}
#else
// Fallback (Mock) para macOS
class WatchSyncManager {
    static let shared = WatchSyncManager()
    func syncDashboard(transactions: [FinancialTransaction]) {
        // No hace nada en Mac
    }
}
#endif
