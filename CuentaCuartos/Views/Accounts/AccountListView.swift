import SwiftUI

struct AccountListView: View {
    @EnvironmentObject private var dataManager: DataManager
    @State private var isShowingAddAccount = false
    @State private var editingAccount: FinancialAccount?
    
    var body: some View {
        Group {
            if dataManager.accounts.isEmpty {
                ContentUnavailableView(
                    "Sin cuentas",
                    systemImage: "creditcard.trianglebadge.exclamationmark",
                    description: Text("Añade tus tarjetas de crédito, cuentas bancarias o efectivo.")
                )
            } else {
                List {
                    ForEach(dataManager.accounts) { account in
                        Button {
                            editingAccount = account
                        } label: {
                            HStack(spacing: 16) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill((Color(hex: account.hexColor) ?? .gray).opacity(0.15))
                                        .frame(width: 48, height: 36)
                                    
                                    Image(systemName: account.symbol)
                                        .foregroundStyle(Color(hex: account.hexColor) ?? .gray)
                                        .font(.headline)
                                }
                                
                                Text(account.name)
                                    .font(.headline)
                            }
                        }
                        .buttonStyle(.plain)
                        .swipeActions(edge: .leading) {
                            Button("Editar") {
                                editingAccount = account
                            }
                            .tint(.blue)
                        }
                    }
                    .onDelete(perform: deleteAccounts)
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
        .navigationTitle("Cuentas y Tarjetas")
        .toolbar {
            ToolbarItem {
                Button(action: {
                    isShowingAddAccount = true
                }) {
                    Label("Añadir Cuenta", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isShowingAddAccount) {
            AddAccountView()
        }
        .sheet(item: $editingAccount) { account in
            AddAccountView(accountToEdit: account)
        }
    }
    
    private func deleteAccounts(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let account = dataManager.accounts[index]
                dataManager.deleteAccount(account)
            }
        }
    }
}
