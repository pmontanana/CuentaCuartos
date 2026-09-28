import SwiftUI

struct ContentView: View {
    @State private var selectedTab: SidebarItem = .dashboard
    @EnvironmentObject private var dataManager: DataManager
    
    @AppStorage("needsMigration") private var needsMigration = false
    @State private var showMigrationAlert = false
    
    var body: some View {
        Group {
            TabView(selection: $selectedTab) {
                ForEach(SidebarItem.allCases, id: \.self) { item in
                    NavigationStack {
                        detailView(for: item)
                    }
                    .tabItem {
                        Label(item.title, systemImage: item.icon)
                    }
                    .tag(item)
                }
            }
        }
        .alert("¿Importar datos locales?", isPresented: $showMigrationAlert) {
            Button("Importar", role: .none) {
                Task {
                    try? await dataManager.migrateOldGlobalData()
                }
                needsMigration = false
            }
            Button("Empezar de cero", role: .cancel) { 
                needsMigration = false
            }
        } message: {
            Text("Hemos detectado que tienes cuentas y movimientos sin vincular a ninguna cuenta. ¿Quieres guardarlos en tu nueva cuenta privada?")
        }
        .onAppear {
            if needsMigration {
                showMigrationAlert = true
            }
        }
    }
    
    @ViewBuilder
    private func detailView(for item: SidebarItem) -> some View {
        switch item {
        case .dashboard:
            DashboardView()
        case .transactions:
            TransactionListView()
        case .categories:
            CategoryListView()
        case .accounts:
            AccountListView()
        case .settings:
            SettingsView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DataManager())
}
