import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @EnvironmentObject private var dataManager: DataManager
    @EnvironmentObject private var authManager: AuthManager
    
    @AppStorage("appCurrency") private var appCurrency: String = "EUR"
    @AppStorage("useSystemTheme") private var useSystemTheme: Bool = true
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("dashboardChartType") private var dashboardChartType: String = "donut"
    
    @State private var showingDeleteAlert = false
    
    let currencies = ["EUR", "USD", "GBP", "JPY", "MXN", "ARS", "CLP", "COP", "PEN"]
    
    var body: some View {
        Form {
            Section("Cuenta") {
                if let user = authManager.currentUser {
                    LabeledContent("Sesión iniciada como", value: user.email ?? "Usuario")
                }
                
                Button(role: .destructive) {
                    authManager.signOut()
                } label: {
                    Label("Cerrar Sesión", systemImage: "rectangle.portrait.and.arrow.right")
                        .foregroundStyle(.red)
                }
            }
            
            Section("Preferencias Visuales y Regionales") {
                Picker("Moneda Principal", selection: $appCurrency) {
                    ForEach(currencies, id: \.self) { currency in
                        Text(currency).tag(currency)
                    }
                }
                
                Toggle("Usar tema del sistema", isOn: $useSystemTheme)
                
                if !useSystemTheme {
                    Toggle("Forzar Modo Oscuro", isOn: $isDarkMode)
                }
            }
            
            Section("Dashboard") {
                Picker("Estilo de gráfica", selection: $dashboardChartType) {
                    Text("Donut de Gastos").tag("donut")
                    Text("Barras Diarias").tag("bar")
                }
                #if os(iOS)
                .pickerStyle(.segmented)
                #endif
            }
            
            Section("Gestión de Datos (Peligro)") {
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Label("Borrar todos los datos", systemImage: "trash.fill")
                        .foregroundStyle(.red)
                }
            }
            
            Section("Acerca de CuentaCuartos") {
                HStack {
                    Text("Versión")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Sincronización")
                    Spacer()
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                    Text("Firebase")
                        .foregroundStyle(.orange)
                }
                HStack {
                    Text("Estado de red")
                    Spacer()
                    Circle()
                        .fill(dataManager.isOnline ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                        .shadow(color: dataManager.isOnline ? .green : .red, radius: 3)
                    Text(dataManager.isOnline ? "Online" : "Offline")
                        .foregroundStyle(dataManager.isOnline ? .green : .red)
                        .font(.body.weight(.medium))
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Ajustes")
        .alert("¿Borrar todos los datos?", isPresented: $showingDeleteAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Borrar Todo", role: .destructive) {
                dataManager.deleteAllData()
            }
        } message: {
            Text("Esta acción no se puede deshacer. Se eliminarán permanentemente todas las transacciones y categorías de Firebase Firestore.")
        }
    }
}
