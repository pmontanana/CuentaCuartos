import SwiftUI

struct AddAccountView: View {
    @EnvironmentObject private var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    var accountToEdit: FinancialAccount?
    
    @State private var name: String
    @State private var symbol: String
    @State private var color: Color
    
    init(accountToEdit: FinancialAccount? = nil) {
        self.accountToEdit = accountToEdit
        _name = State(initialValue: accountToEdit?.name ?? "")
        _symbol = State(initialValue: accountToEdit?.symbol ?? "creditcard.fill")
        if let hex = accountToEdit?.hexColor, let uiColor = Color(hex: hex) {
            _color = State(initialValue: uiColor)
        } else {
            _color = State(initialValue: .blue)
        }
    }
    
    let predefinedSymbols = [
        "creditcard.fill", "banknote.fill", "building.columns.fill", "dollarsign.circle.fill",
        "apple.logo", "wallet.pass.fill", "briefcase.fill", "lanyardcard.fill"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Estilo de la cuenta") {
                    HStack {
                        Spacer()
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(color.gradient)
                                .frame(width: 120, height: 75)
                                .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
                            
                            Image(systemName: symbol)
                                .font(.system(size: 30))
                                .foregroundStyle(.white)
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                    
                    ColorPicker("Color base", selection: $color)
                }
                
                Section("Identificación") {
                    TextField("Nombre (ej: Tarjeta Visa, Efectivo)", text: $name)
                }
                
                Section("Elige un icono") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 12) {
                        ForEach(predefinedSymbols, id: \.self) { sym in
                            Button {
                                symbol = sym
                            } label: {
                                Image(systemName: sym)
                                    .font(.title2)
                                    .frame(width: 44, height: 44)
                                    .background(symbol == sym ? color.opacity(0.2) : Color.clear)
                                    .foregroundStyle(symbol == sym ? color : .primary)
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .formStyle(.grouped)
            .navigationTitle(accountToEdit == nil ? "Nueva Cuenta" : "Editar Cuenta")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { saveAccount() }
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        #if os(macOS)
        .frame(width: 450, height: 500)
        #endif
    }
    
    private func saveAccount() {
        if let account = accountToEdit {
            var updated = account
            updated.name = name
            updated.symbol = symbol
            updated.hexColor = color.toHex()
            dataManager.updateAccount(updated)
        } else {
            let newAccount = FinancialAccount(
                name: name,
                symbol: symbol,
                hexColor: color.toHex()
            )
            dataManager.addAccount(newAccount)
        }
        dismiss()
    }
}
