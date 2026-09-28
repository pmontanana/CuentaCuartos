import SwiftUI

struct TransactionListView: View {
    @EnvironmentObject private var dataManager: DataManager
    @State private var isShowingAddTransaction = false
    @State private var editingTransaction: FinancialTransaction?
    @State private var detailingTransaction: FinancialTransaction?
    
    @State private var selectedCategoryId: String?
    @State private var selectedAccountId: String?
    @State private var selectedType: TransactionType?
    @State private var searchText = ""
    
    @State private var isShowingPriceFilters = false
    @State private var minAmount: Double?
    @State private var maxAmount: Double?
    
    private var filteredTransactions: [FinancialTransaction] {
        dataManager.transactions.filter { transaction in
            // Filtros de Picker
            let matchCategory = selectedCategoryId == nil || transaction.categoryId == selectedCategoryId
            let matchAccount = selectedAccountId == nil || transaction.accountId == selectedAccountId
            let matchType = selectedType == nil || transaction.type == selectedType
            
            // Filtros de Precio
            let matchMin = minAmount == nil || transaction.amount >= minAmount!
            let matchMax = maxAmount == nil || transaction.amount <= maxAmount!
            
            // Búsqueda por texto (nota, nombre categoría, nombre tarjeta)
            let matchSearch: Bool
            if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                matchSearch = true
            } else {
                let matchNote = transaction.notes.localizedStandardContains(searchText)
                let matchCatName = (transaction.categoryName ?? "").localizedStandardContains(searchText)
                let matchAccName = (transaction.accountName ?? "").localizedStandardContains(searchText)
                
                matchSearch = matchNote || matchCatName || matchAccName
            }
            
            return matchCategory && matchAccount && matchType && matchSearch && matchMin && matchMax
        }
    }
    
    var body: some View {
        Group {
            if dataManager.transactions.isEmpty {
                ContentUnavailableView(
                    "Sin movimientos",
                    systemImage: "list.bullet.rectangle.portrait",
                    description: Text("Tus transacciones aparecerán aquí una vez que las registres.")
                )
            } else if filteredTransactions.isEmpty && !isShowingPriceFilters {
                ContentUnavailableView(
                    "No hay resultados",
                    systemImage: "magnifyingglass",
                    description: Text("Ningún movimiento coincide con tu búsqueda o filtros.")
                )
            } else {
                List {
                    if isShowingPriceFilters {
                        Section("Filtro de Precio (€)") {
                            HStack {
                                TextField("Mín", value: $minAmount, format: .number)
                                    #if os(iOS)
                                    .keyboardType(.decimalPad)
                                    #endif
                                    .multilineTextAlignment(.center)
                                
                                Divider()
                                
                                TextField("Máx", value: $maxAmount, format: .number)
                                    #if os(iOS)
                                    .keyboardType(.decimalPad)
                                    #endif
                                    .multilineTextAlignment(.center)
                                
                                if minAmount != nil || maxAmount != nil {
                                    Button {
                                        minAmount = nil
                                        maxAmount = nil
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                    
                    ForEach(filteredTransactions) { transaction in
                        TransactionRowView(
                            transaction: transaction,
                            onEdit: { editingTransaction = transaction },
                            onDetail: { detailingTransaction = transaction }
                        )
                        .swipeActions(edge: .leading) {
                            Button("Editar") {
                                editingTransaction = transaction
                            }
                            .tint(.blue)
                        }
                    }
                    .onDelete(perform: deleteTransactions)
                }
                #if os(macOS)
                .listStyle(.inset)
                #else
                .listStyle(.insetGrouped)
                #endif
                .refreshable {
                    await dataManager.refreshData()
                }
            }
        }
        .searchable(text: $searchText, prompt: "Buscar concepto, tarjeta...")
        .navigationTitle("Movimientos")
        .toolbar {
            ToolbarItemGroup {
                Menu {
                    Picker("Tipo", selection: $selectedType) {
                        Text("Todos los tipos").tag(TransactionType?.none)
                        Text("Ingresos").tag(TransactionType?.some(.income))
                        Text("Gastos").tag(TransactionType?.some(.expense))
                    }
                    
                    Picker("Categoría", selection: $selectedCategoryId) {
                        Text("Todas las categorías").tag(String?.none)
                        ForEach(dataManager.categories) { category in
                            Text(category.name).tag(String?(category.id ?? ""))
                        }
                    }
                    
                    Picker("Cuenta / Tarjeta", selection: $selectedAccountId) {
                        Text("Todas las cuentas").tag(String?.none)
                        ForEach(dataManager.accounts) { account in
                            Text(account.name).tag(String?(account.id ?? ""))
                        }
                    }
                    
                    Divider()
                    
                    Toggle(isOn: $isShowingPriceFilters) {
                        Label("Filtro por Precio", systemImage: "eurosign.circle")
                    }
                    
                    if selectedCategoryId != nil || selectedAccountId != nil || selectedType != nil || minAmount != nil || maxAmount != nil || isShowingPriceFilters {
                        Divider()
                        Button(role: .destructive, action: {
                            withAnimation {
                                selectedCategoryId = nil
                                selectedAccountId = nil
                                selectedType = nil
                                minAmount = nil
                                maxAmount = nil
                                searchText = ""
                                isShowingPriceFilters = false
                            }
                        }) {
                            Label("Borrar Filtros", systemImage: "xmark.circle")
                        }
                    }
                } label: {
                    let hasFilters = selectedCategoryId != nil || selectedAccountId != nil || selectedType != nil || minAmount != nil || maxAmount != nil
                    Label("Filtros", systemImage: hasFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                        .foregroundStyle(hasFilters ? .blue : .primary)
                }
                
                Button(action: {
                    isShowingAddTransaction = true
                }) {
                    Label("Añadir Movimiento", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isShowingAddTransaction) {
            AddTransactionView()
        }
        .sheet(item: $editingTransaction) { transaction in
            AddTransactionView(transactionToEdit: transaction)
        }
        .sheet(item: $detailingTransaction) { transaction in
            TransactionDetailView(transaction: transaction)
        }
    }
    
    private func deleteTransactions(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let transaction = filteredTransactions[index]
                dataManager.deleteTransaction(transaction)
            }
        }
    }
}
