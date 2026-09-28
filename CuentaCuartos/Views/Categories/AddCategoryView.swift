import SwiftUI

struct AddCategoryView: View {
    @EnvironmentObject private var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    var categoryToEdit: TransactionCategory?
    
    @State private var name: String
    @State private var symbol: String
    @State private var color: Color
    
    init(categoryToEdit: TransactionCategory? = nil) {
        self.categoryToEdit = categoryToEdit
        _name = State(initialValue: categoryToEdit?.name ?? "")
        _symbol = State(initialValue: categoryToEdit?.symbol ?? "cart.fill")
        if let hex = categoryToEdit?.hexColor, let uiColor = Color(hex: hex) {
            _color = State(initialValue: uiColor)
        } else {
            _color = State(initialValue: .blue)
        }
    }
    
    let predefinedSymbols = [
        "cart.fill", "fork.knife", "car.fill", "house.fill", "bolt.fill",
        "drop.fill", "cross.case.fill", "graduationcap.fill", "airplane",
        "gamecontroller.fill", "tv.fill", "display", "bag.fill", "gift.fill",
        "heart.fill", "star.fill", "leaf.fill", "music.note"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Icono y Color") {
                    HStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(color.opacity(0.2))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: symbol)
                                .font(.system(size: 40))
                                .foregroundStyle(color)
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                    
                    ColorPicker("Color de la categoría", selection: $color)
                }
                
                Section("Nombre") {
                    TextField("Ej: Supermercado", text: $name)
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
            .navigationTitle(categoryToEdit == nil ? "Nueva Categoría" : "Editar Categoría")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { saveCategory() }
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        #if os(macOS)
        .frame(width: 450, height: 550)
        #endif
    }
    
    private func saveCategory() {
        if let category = categoryToEdit {
            var updated = category
            updated.name = name
            updated.symbol = symbol
            updated.hexColor = color.toHex()
            dataManager.updateCategory(updated)
        } else {
            let newCategory = TransactionCategory(
                name: name,
                symbol: symbol,
                hexColor: color.toHex()
            )
            dataManager.addCategory(newCategory)
        }
        dismiss()
    }
}
