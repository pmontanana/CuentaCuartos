import Foundation
import FirebaseFirestore

struct TransactionCategory: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var symbol: String
    var hexColor: String
    
    init(id: String? = nil, name: String, symbol: String, hexColor: String) {
        self.id = id
        self.name = name
        self.symbol = symbol
        self.hexColor = hexColor
    }
}
