import Foundation
import FirebaseFirestore

enum TransactionType: String, Codable {
    case income = "Ingreso"
    case expense = "Gasto"
}

struct FinancialTransaction: Codable, Identifiable {
    @DocumentID var id: String?
    var amount: Double
    var date: Date
    var type: TransactionType
    var notes: String
    
    // Datos desnormalizados de la categoría
    var categoryId: String?
    var categoryName: String?
    var categorySymbol: String?
    var categoryHexColor: String?
    
    // Datos desnormalizados de la cuenta/tarjeta
    var accountId: String?
    var accountName: String?
    var accountSymbol: String?
    var accountHexColor: String?
    
    init(id: String? = nil, amount: Double, date: Date = .now, type: TransactionType, notes: String = "", category: TransactionCategory? = nil, account: FinancialAccount? = nil) {
        self.id = id
        self.amount = amount
        self.date = date
        self.type = type
        self.notes = notes
        
        if let cat = category {
            self.categoryId = cat.id
            self.categoryName = cat.name
            self.categorySymbol = cat.symbol
            self.categoryHexColor = cat.hexColor
        }
        
        if let acc = account {
            self.accountId = acc.id
            self.accountName = acc.name
            self.accountSymbol = acc.symbol
            self.accountHexColor = acc.hexColor
        }
    }
}
