import Foundation

enum SidebarItem: CaseIterable {
    case dashboard, transactions, categories, accounts, settings
    
    var title: String {
        switch self {
        case .dashboard: return "Resumen"
        case .transactions: return "Movimientos"
        case .categories: return "Categorías"
        case .accounts: return "Cuentas y Tarjetas"
        case .settings: return "Ajustes"
        }
    }
    
    var icon: String {
        switch self {
        case .dashboard: return "chart.pie"
        case .transactions: return "list.bullet.rectangle"
        case .categories: return "folder"
        case .accounts: return "creditcard"
        case .settings: return "gear"
        }
    }
}
