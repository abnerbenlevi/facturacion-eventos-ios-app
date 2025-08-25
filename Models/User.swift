//
//  User.swift
//  Billing & Events App
//
//  User data model
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    var name: String
    var email: String
    var password: String // Note: In production, use secure storage like Keychain
    var createdAt: Date
    
    init(name: String, email: String, password: String) {
        self.id = UUID().uuidString
        self.name = name
        self.email = email
        self.password = password
        self.createdAt = Date()
    }
}

// MARK: - User Extensions
extension User {
    var displayName: String {
        return name.isEmpty ? email : name
    }
    
    func isValidEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
