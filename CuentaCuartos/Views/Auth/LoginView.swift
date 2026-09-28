import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var dataManager: DataManager
    
    @State private var email = ""
    @State private var password = ""
    @State private var isRegistering = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @AppStorage("needsMigration") private var needsMigration = false
    
    var body: some View {
        ZStack {
            // Fondo animado/premium
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ).ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Logo o Icono
                Image(systemName: "banknote.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom)
                    )
                    .padding(.bottom, 20)
                
                Text(isRegistering ? "Crear Cuenta" : "Iniciar Sesión")
                    .font(.largeTitle.weight(.bold))
                
                VStack(spacing: 16) {
                    TextField("Correo electrónico", text: $email)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        #if os(iOS)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        #endif
                    
                    SecureField("Contraseña", text: $password)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 32)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Button(action: {
                    Task {
                        await authenticate()
                    }
                }) {
                    HStack {
                        if isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text(isRegistering ? "Registrarse" : "Entrar")
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 32)
                .disabled(isLoading || email.isEmpty || password.isEmpty)
                
                Button(action: {
                    withAnimation {
                        isRegistering.toggle()
                        errorMessage = ""
                    }
                }) {
                    Text(isRegistering ? "¿Ya tienes cuenta? Inicia Sesión" : "¿No tienes cuenta? Regístrate")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    private func authenticate() async {
        isLoading = true
        errorMessage = ""
        do {
            if isRegistering {
                needsMigration = true
                try await authManager.signUp(email: email, password: password)
            } else {
                try await authManager.signIn(email: email, password: password)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
