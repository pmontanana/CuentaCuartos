import SwiftUI

struct TransactionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var dataManager: DataManager
    var transaction: FinancialTransaction
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .center, spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(categoryColor.gradient.opacity(0.12))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: categoryIcon)
                                .foregroundStyle(categoryColor.gradient)
                                .font(.system(size: 32, weight: .semibold))
                        }
                        
                        Text(displayCategoryName)
                            .font(.title2.weight(.bold))
                        
                        Text("\(transaction.type == .income ? "+" : "-")\(abs(transaction.amount), format: .currency(code: "EUR"))")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundStyle(transaction.type == .income ? Color.green : Color.red)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .listRowBackground(Color.clear)
                }
                
                Section("Detalles") {
                    LabeledContent("Tipo", value: transaction.type == .income ? "Ingreso" : "Gasto")
                    LabeledContent("Fecha", value: transaction.date.formatted(date: .long, time: .shortened))
                    
                    if let account = displayAccountName {
                        LabeledContent {
                            Text(account)
                        } label: {
                            Label("Cuenta", systemImage: displayAccountSymbol ?? "creditcard")
                        }
                    }
                }
                
                if !transaction.notes.isEmpty {
                    Section("Notas") {
                        Text(transaction.notes)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Detalle")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
        #if os(macOS)
        .frame(width: 400, height: 500)
        #endif
    }
    
    // Helpers
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
