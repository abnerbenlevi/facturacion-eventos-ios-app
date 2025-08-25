//
//  RegistrationView.swift
//  Billing & Events App
//
//  User registration interface
//

import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 32) {
                        // Header Section
                        VStack(spacing: 16) {
                            // App Icon
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Text("FE")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                )
                            
                            VStack(spacing: 4) {
                                Text("Crear Cuenta")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Text("Únete y comienza a gestionar tu negocio")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Registration Form
                        VStack(spacing: 20) {
                            // Name Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Nombre Completo")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                
                                TextField("Tu nombre completo", text: $name)
                                    .textFieldStyle(IOSTextFieldStyle())
                                    .textContentType(.name)
                                    .autocapitalization(.words)
                            }
                            
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
                                
                                SecureField("Mínimo 6 caracteres", text: $password)
                                    .textFieldStyle(IOSTextFieldStyle())
                                    .textContentType(.newPassword)
                            }
                            
                            // Confirm Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Confirmar Contraseña")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                
                                SecureField("Confirma tu contraseña", text: $confirmPassword)
                                    .textFieldStyle(IOSTextFieldStyle())
                                    .textContentType(.newPassword)
                            }
                            
                            // Password Requirements
                            if !password.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 8) {
                                        Image(systemName: password.count >= 6 ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(password.count >= 6 ? .green : .gray)
                                            .font(.caption)
                                        
                                        Text("Mínimo 6 caracteres")
                                            .font(.caption)
                                            .foregroundColor(password.count >= 6 ? .green : .gray)
                                    }
                                    
                                    HStack(spacing: 8) {
                                        Image(systemName: password == confirmPassword && !confirmPassword.isEmpty ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(password == confirmPassword && !confirmPassword.isEmpty ? .green : .gray)
                                            .font(.caption)
                                        
                                        Text("Las contraseñas coinciden")
                                            .font(.caption)
                                            .foregroundColor(password == confirmPassword && !confirmPassword.isEmpty ? .green : .gray)
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                        }
                        
                        // Register Button
                        VStack(spacing: 16) {
                            Button(action: {
                                userViewModel.register(
                                    name: name,
                                    email: email,
                                    password: password,
                                    confirmPassword: confirmPassword
                                )
                            }) {
                                HStack {
                                    if userViewModel.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Text("Crear Cuenta")
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
                            .disabled(userViewModel.isLoading || !isFormValid)
                            .opacity((userViewModel.isLoading || !isFormValid) ? 0.6 : 1.0)
                            
                            // Login Link
                            Button(action: {
                                dismiss()
                            }) {
                                HStack(spacing: 4) {
                                    Text("¿Ya tienes cuenta?")
                                        .foregroundColor(.secondary)
                                    Text("Inicia Sesión")
                                        .foregroundColor(.blue)
                                        .fontWeight(.medium)
                                }
                                .font(.subheadline)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 32)
                }
            }
            .navigationTitle("Registro")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
            .background(Color(.systemGroupedBackground))
            .alert("Error", isPresented: $userViewModel.showAlert) {
                Button("OK") {
                    userViewModel.clearError()
                }
            } message: {
                Text(userViewModel.errorMessage)
            }
            .onChange(of: userViewModel.isLoggedIn) { isLoggedIn in
                if isLoggedIn {
                    dismiss()
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               password.count >= 6 &&
               password == confirmPassword
    }
}

#Preview {
    RegistrationView()
        .environmentObject(UserViewModel())
}
