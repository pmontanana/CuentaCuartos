import SwiftUI

struct CategoryListView: View {
    @EnvironmentObject private var dataManager: DataManager
    @State private var isShowingAddCategory = false
    @State private var editingCategory: TransactionCategory?
    
    var body: some View {
        Group {
            if dataManager.categories.isEmpty {
                ContentUnavailableView(
                    "Sin categorías",
                    systemImage: "folder.badge.plus",
                    description: Text("Crea categorías como 'Supermercado' u 'Ocio' para organizar tus gastos.")
                )
            } else {
                List {
                    ForEach(dataManager.categories) { category in
                        Button {
                            editingCategory = category
                        } label: {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill((Color(hex: category.hexColor) ?? .gray).opacity(0.2))
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: category.symbol)
                                        .foregroundStyle(Color(hex: category.hexColor) ?? .gray)
                                        .font(.title3)
                                }
                                
                                Text(category.name)
                                    .font(.headline)
                            }
                        }
                        .buttonStyle(.plain)
                        .swipeActions(edge: .leading) {
                            Button("Editar") {
                                editingCategory = category
                            }
                            .tint(.blue)
                        }
                    }
                    .onDelete(perform: deleteCategories)
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
        .navigationTitle("Categorías")
        .toolbar {
            ToolbarItem {
                Button(action: {
                    isShowingAddCategory = true
                }) {
                    Label("Añadir Categoría", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isShowingAddCategory) {
            AddCategoryView()
        }
        .sheet(item: $editingCategory) { category in
            AddCategoryView(categoryToEdit: category)
        }
    }
    
    private func deleteCategories(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let category = dataManager.categories[index]
                dataManager.deleteCategory(category)
            }
        }
    }
}
