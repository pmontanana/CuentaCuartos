import SwiftUI

struct TransactionRowView: View {
    @EnvironmentObject private var dataManager: DataManager
    var transaction: FinancialTransaction
    
    var onEdit: (() -> Void)? = nil
    var onDetail: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 16) {
            // Icono de la categoría estilo premium
            Button(action: {
                onEdit?()
            }) {
                ZStack {
                    Circle()
                        .fill(categoryColor.gradient.opacity(0.12))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: categoryIcon)
                        .foregroundStyle(categoryColor.gradient)
                        .font(.system(size: 20, weight: .semibold))
                }
            }
            .buttonStyle(.plain)
            
            // Contenedor pulsable para el detalle
            Button(action: {
                onDetail?()
            }) {
                HStack {
                    // Detalles principales
                    VStack(alignment: .leading, spacing: 4) {
                        Text(displayCategoryName)
                            .font(.system(size: 17, weight: .semibold, design: .default))
                            .foregroundStyle(.primary)
                        
                        if !transaction.notes.isEmpty || displayAccountName != nil {
                            HStack(spacing: 6) {
                                if let accName = displayAccountName {
                                    Label(accName, systemImage: displayAccountSymbol ?? "creditcard")
                                }
                                if !transaction.notes.isEmpty {
                                    Text(displayAccountName != nil ? "- \(transaction.notes)" : transaction.notes)
                                }
                            }
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                    
                    // Cantidad y fecha
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(transaction.type == .income ? "+" : "-")\(abs(transaction.amount), format: .currency(code: "EUR"))")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(transaction.type == .income ? Color.green : Color.red)
                        
                        Text(transaction.date, format: .dateTime.day().month())
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }
    // Helpers para coger el dato vivo (si existe) o el guardado (si se eliminó)
    
    private var liveCategory: TransactionCategory? {
        guard let id = transaction.categoryId else { return nil }
        return dataManager.categories.first { $0.id == id }
    }
    
    private var liveAccount: FinancialAccount? {
        guard let id = transaction.accountId else { return nil }
        return dataManager.accounts.first { $0.id == id }
    }
    
    private var displayCategoryName: String {
        liveCategory?.name ?? transaction.categoryName ?? (transaction.type == .income ? "Ingreso" : "Gasto")
    }
    
    private var displayAccountName: String? {
        liveAccount?.name ?? transaction.accountName
    }
    
    private var displayAccountSymbol: String? {
        liveAccount?.symbol ?? transaction.accountSymbol
    }
    
    private var categoryColor: Color {
        let hex = liveCategory?.hexColor ?? transaction.categoryHexColor
        if let hex = hex, let color = Color(hex: hex) {
            return color
        }
        return transaction.type == .income ? .green : .red
    }
    
    private var categoryIcon: String {
        return liveCategory?.symbol ?? transaction.categorySymbol ?? (transaction.type == .income ? "arrow.down.left" : "arrow.up.right")
    }
}
