//
//  UserViewModel.swift
//  Billing & Events App
//
//  User management and authentication logic
//

import Foundation
import Combine

class UserViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var showAlert: Bool = false
    
    private let dataService = DataService.shared
    
    init() {
        loadCurrentUser()
    }
    
    // MARK: - Authentication Methods
    
    func register(name: String, email: String, password: String, confirmPassword: String) {
        // Reset error state
        errorMessage = ""
        isLoading = true
        
        // Validation
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showError("El nombre es requerido")
            return
        }
        
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showError("El email es requerido")
            return
        }
        
        guard !password.isEmpty else {
            showError("La contraseña es requerida")
            return
        }
        
        guard password == confirmPassword else {
            showError("Las contraseñas no coinciden")
            return
        }
        
        guard password.count >= 6 else {
            showError("La contraseña debe tener al menos 6 caracteres")
            return
        }
        
        let tempUser = User(name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                           email: email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
                           password: password)
        
        guard tempUser.isValidEmail() else {
            showError("Por favor ingresa un email válido")
            return
        }
        
        // Check if user already exists
        if dataService.userExists(email: tempUser.email) {
            showError("Ya existe un usuario con este email")
            return
        }
        
        // Save user
        if dataService.saveUser(tempUser) {
            DispatchQueue.main.async {
                self.currentUser = tempUser
                self.isLoggedIn = true
                self.isLoading = false
            }
        } else {
            showError("Error al crear la cuenta. Intenta nuevamente.")
        }
    }
    
    func login(email: String, password: String) {
        // Reset error state
        errorMessage = ""
        isLoading = true
        
        // Validation
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showError("El email es requerido")
            return
        }
        
        guard !password.isEmpty else {
            showError("La contraseña es requerida")
            return
        }
        
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // Authenticate user
        if let user = dataService.authenticateUser(email: cleanEmail, password: password) {
            DispatchQueue.main.async {
                self.currentUser = user
                self.isLoggedIn = true
                self.isLoading = false
                self.saveCurrentUser()
            }
        } else {
            showError("Email o contraseña incorrectos")
        }
    }
    
    func logout() {
        DispatchQueue.main.async {
            self.currentUser = nil
            self.isLoggedIn = false
            self.errorMessage = ""
            self.clearCurrentUser()
        }
    }
    
    // MARK: - User Persistence
    
    func loadCurrentUser() {
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            DispatchQueue.main.async {
                self.currentUser = user
                self.isLoggedIn = true
            }
        }
    }
    
    private func saveCurrentUser() {
        guard let user = currentUser else { return }
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: "currentUser")
        }
    }
    
    private func clearCurrentUser() {
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }
    
    // MARK: - Helper Methods
    
    private func showError(_ message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
            self.showAlert = true
            self.isLoading = false
        }
    }
    
    func clearError() {
        errorMessage = ""
        showAlert = false
    }
    
    // MARK: - User Management
    
    func updateUserProfile(name: String, email: String) {
        guard var user = currentUser else { return }
        
        // Validation
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showError("El nombre es requerido")
            return
        }
        
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        guard User(name: cleanName, email: cleanEmail, password: "temp").isValidEmail() else {
            showError("Por favor ingresa un email válido")
            return
        }
        
        // Check if email is already taken by another user
        if cleanEmail != user.email && dataService.userExists(email: cleanEmail) {
            showError("Ya existe un usuario con este email")
            return
        }
        
        // Update user
        user.name = cleanName
        user.email = cleanEmail
        
        if dataService.updateUser(user) {
            DispatchQueue.main.async {
                self.currentUser = user
                self.saveCurrentUser()
            }
        } else {
            showError("Error al actualizar el perfil")
        }
    }
}
