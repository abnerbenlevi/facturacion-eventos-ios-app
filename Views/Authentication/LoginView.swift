//
//  LoginView.swift
//  Billing & Events App
//
//  User login interface
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showRegistration: Bool = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        // Header Section
                        VStack(spacing: 20) {
                            Spacer()
                            
                            // App Icon/Logo
                            VStack(spacing: 12) {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.blue, .purple],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        Text("FE")
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    )
                                
                                VStack(spacing: 4) {
                                    Text("Facturación & Eventos")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    
                                    Text("Gestiona tu negocio de forma inteligente")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            
                            Spacer()
                        }
                        .frame(height: geometry.size.height * 0.4)
                        
                        // Login Form Section
                        VStack(spacing: 24) {
                            VStack(spacing: 16) {
                                // Email Field
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Email")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    
                                    TextField("tu@email.com", text: $email)
                                        .textFieldStyle(IOSTextFieldStyle())
                                        .keyboardType(.emailAddress)
                                        .textContentType(.emailAddress)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                }
                                
                                // Password Field
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Contraseña")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    
                                    SecureField("Ingresa tu contraseña", text: $password)
                                        .textFieldStyle(IOSTextFieldStyle())
                                        .textContentType(.password)
                                }
                            }
                            
                            // Login Button
                            Button(action: {
                                userViewModel.login(email: email, password: password)
                            }) {
                                HStack {
                                    if userViewModel.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Text("Iniciar Sesión")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(userViewModel.isLoading || email.isEmpty || password.isEmpty)
                            .opacity((userViewModel.isLoading || email.isEmpty || password.isEmpty) ? 0.6 : 1.0)
                            
                            // Register Link
                            Button(action: {
                                showRegistration = true
                            }) {
                                HStack(spacing: 4) {
                                    Text("¿No tienes cuenta?")
                                        .foregroundColor(.secondary)
                                    Text("Regístrate")
                                        .foregroundColor(.blue)
                                        .fontWeight(.medium)
                                }
                                .font(.subheadline)
                            }
                        }
                        .padding(.horizontal, 32)
                        .frame(minHeight: geometry.size.height * 0.6)
                    }
                }
            }
            .navigationBarHidden(true)
            .background(Color(.systemGroupedBackground))
            .alert("Error", isPresented: $userViewModel.showAlert) {
                Button("OK") {
                    userViewModel.clearError()
                }
            } message: {
                Text(userViewModel.errorMessage)
            }
            .sheet(isPresented: $showRegistration) {
                RegistrationView()
            }
        }
    }
}

// MARK: - Custom Text Field Style
struct IOSTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
    }
}

#Preview {
    LoginView()
        .environmentObject(UserViewModel())
}
