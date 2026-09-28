import Foundation

struct WatchDashboardData: Codable {
    var totalBalance: Double
    var totalIncome: Double
    var totalExpenses: Double
    
    var recentIncomes: [Double]
    var recentExpenses: [Double]
    var recentTransactions: [WatchTransaction]
}

struct WatchTransaction: Codable, Identifiable {
    var id: String
    var amount: Double
    var type: String
    var date: Date
    var categorySymbol: String
    var categoryHexColor: String
}
