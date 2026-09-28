import SwiftUI

struct AddTransactionView: View {
    @EnvironmentObject private var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    var transactionToEdit: FinancialTransaction?
    
    @State private var amount: Double?
    @State private var date: Date
    @State private var type: TransactionType
    @State private var notes: String
    @State private var selectedCategoryId: String?
    @State private var selectedAccountId: String?
    
    init(transactionToEdit: FinancialTransaction? = nil) {
        self.transactionToEdit = transactionToEdit
        _amount = State(initialValue: transactionToEdit?.amount)
        _date = State(initialValue: transactionToEdit?.date ?? .now)
        _type = State(initialValue: transactionToEdit?.type ?? .expense)
        _notes = State(initialValue: transactionToEdit?.notes ?? "")
        _selectedCategoryId = State(initialValue: transactionToEdit?.categoryId)
        _selectedAccountId = State(initialValue: transactionToEdit?.accountId)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Detalles Principales") {
                    Picker("Tipo", selection: $type) {
                        Text("Ingreso").tag(TransactionType.income)
                        Text("Gasto").tag(TransactionType.expense)
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 8)
                    
                    TextField("Cantidad", value: $amount, format: .currency(code: "EUR"))
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(type == .income ? .green : .red)
                    
                    DatePicker("Fecha", selection: $date, displayedComponents: .date)
                }
                
                Section("Categoría y Cuenta") {
                    if dataManager.categories.isEmpty {
                        Text("No hay categorías creadas.")
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("Categoría", selection: $selectedCategoryId) {
                            Text("Ninguna").tag(String?.none)
                            ForEach(dataManager.categories) { category in
                                Text(category.name).tag(category.id as String?)
                            }
                        }
                    }
                    
                    if dataManager.accounts.isEmpty {
                        Text("No hay cuentas creadas.")
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("Cuenta / Tarjeta", selection: $selectedAccountId) {
                            Text("Ninguna").tag(String?.none)
                            ForEach(dataManager.accounts) { account in
                                Text(account.name).tag(account.id as String?)
                            }
                        }
                    }
                }
                
                Section("Notas Adicionales") {
                    TextField("Ej: Compra semanal", text: $notes)
                }
            }
            .formStyle(.grouped)
            .navigationTitle(transactionToEdit == nil ? (type == .income ? "Nuevo Ingreso" : "Nuevo Gasto") : "Editar Movimiento")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { saveTransaction() }
                        .disabled(amount == nil || amount! <= 0)
                }
            }
        }
        #if os(macOS)
        .frame(width: 450, height: 550)
        #endif
    }
    
    private func saveTransaction() {
        guard let finalAmount = amount else { return }
        
        var selectedCategory: TransactionCategory? = nil
        if let catId = selectedCategoryId {
            selectedCategory = dataManager.categories.first { $0.id == catId }
        }
        
        var selectedAccount: FinancialAccount? = nil
        if let accId = selectedAccountId {
            selectedAccount = dataManager.accounts.first { $0.id == accId }
        }
        
        if let transaction = transactionToEdit {
            var updated = transaction
            updated.amount = finalAmount
            updated.date = date
            updated.type = type
            updated.notes = notes
            updated.categoryId = selectedCategory?.id
            updated.categoryName = selectedCategory?.name
            updated.categorySymbol = selectedCategory?.symbol
            updated.categoryHexColor = selectedCategory?.hexColor
            updated.accountId = selectedAccount?.id
            updated.accountName = selectedAccount?.name
            updated.accountSymbol = selectedAccount?.symbol
            updated.accountHexColor = selectedAccount?.hexColor
            dataManager.updateTransaction(updated)
        } else {
            let newTransaction = FinancialTransaction(
                amount: finalAmount,
                date: date,
                type: type,
                notes: notes,
                category: selectedCategory,
                account: selectedAccount
            )
            dataManager.addTransaction(newTransaction)
        }
        
        dismiss()
    }
}
