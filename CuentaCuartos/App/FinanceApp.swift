import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct FinanceApp: App {
    @AppStorage("useSystemTheme") private var useSystemTheme: Bool = true
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    @StateObject private var authManager = AuthManager()
    @StateObject private var dataManager = DataManager()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    ContentView()
                } else {
                    LoginView()
                }
            }
            .preferredColorScheme(useSystemTheme ? nil : (isDarkMode ? .dark : .light))
            .environmentObject(authManager)
            .environmentObject(dataManager)
            .onChange(of: authManager.currentUser?.uid) { oldValue, newValue in
                dataManager.userId = newValue
            }
            .onAppear {
                dataManager.userId = authManager.currentUser?.uid
            }
        }
    }
}
