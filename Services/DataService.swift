//
//  DataService.swift
//  Billing & Events App
//
//  Local data storage and management service
//

import Foundation

class DataService {
    static let shared = DataService()
    
    private let userDefaults = UserDefaults.standard
    
    // Keys for UserDefaults
    private let usersKey = "saved_users"
    private let invoicesKey = "saved_invoices"
    private let eventsKey = "saved_events"
    
    private init() {}
    
    // MARK: - User Management
    
    func saveUser(_ user: User) -> Bool {
        var users = loadAllUsers()
        
        // Check if user already exists
        if users.contains(where: { $0.email == user.email }) {
            return false
        }
        
        users.append(user)
        return saveUsers(users)
    }
    
    func updateUser(_ user: User) -> Bool {
        var users = loadAllUsers()
        
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index] = user
            return saveUsers(users)
        }
        
        return false
    }
    
    func deleteUser(_ userId: String) -> Bool {
        var users = loadAllUsers()
        users.removeAll { $0.id == userId }
        
        // Also delete all user's invoices and events
        _ = deleteAllInvoices(for: userId)
        _ = deleteAllEvents(for: userId)
        
        return saveUsers(users)
    }
    
    func authenticateUser(email: String, password: String) -> User? {
        let users = loadAllUsers()
        return users.first { $0.email == email && $0.password == password }
    }
    
    func userExists(email: String) -> Bool {
        let users = loadAllUsers()
        return users.contains { $0.email == email }
    }
    
    func loadAllUsers() -> [User] {
        guard let data = userDefaults.data(forKey: usersKey),
              let users = try? JSONDecoder().decode([User].self, from: data) else {
            return []
        }
        return users
    }
    
    private func saveUsers(_ users: [User]) -> Bool {
        guard let data = try? JSONEncoder().encode(users) else {
            return false
        }
        userDefaults.set(data, forKey: usersKey)
        return true
    }
    
    // MARK: - Invoice Management
    
    func saveInvoice(_ invoice: Invoice) -> Bool {
        var invoices = loadAllInvoices()
        invoices.append(invoice)
        return saveInvoices(invoices)
    }
    
    func updateInvoice(_ invoice: Invoice) -> Bool {
        var invoices = loadAllInvoices()
        
        if let index = invoices.firstIndex(where: { $0.id == invoice.id }) {
            invoices[index] = invoice
            return saveInvoices(invoices)
        }
        
        return false
    }
    
    func deleteInvoice(_ invoiceId: String) -> Bool {
        var invoices = loadAllInvoices()
        invoices.removeAll { $0.id == invoiceId }
        return saveInvoices(invoices)
    }
    
    func loadInvoices(for userId: String) -> [Invoice] {
        let allInvoices = loadAllInvoices()
        return allInvoices.filter { $0.userId == userId }
    }
    
    func deleteAllInvoices(for userId: String) -> Bool {
        var invoices = loadAllInvoices()
        invoices.removeAll { $0.userId == userId }
        return saveInvoices(invoices)
    }
    
    private func loadAllInvoices() -> [Invoice] {
        guard let data = userDefaults.data(forKey: invoicesKey),
              let invoices = try? JSONDecoder().decode([Invoice].self, from: data) else {
            return []
        }
        return invoices
    }
    
    private func saveInvoices(_ invoices: [Invoice]) -> Bool {
        guard let data = try? JSONEncoder().encode(invoices) else {
            return false
        }
        userDefaults.set(data, forKey: invoicesKey)
        return true
    }
    
    // MARK: - Event Management
    
    func saveEvent(_ event: Event) -> Bool {
        var events = loadAllEvents()
        events.append(event)
        return saveEvents(events)
    }
    
    func updateEvent(_ event: Event) -> Bool {
        var events = loadAllEvents()
        
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event
            return saveEvents(events)
        }
        
        return false
    }
    
    func deleteEvent(_ eventId: String) -> Bool {
        var events = loadAllEvents()
        events.removeAll { $0.id == eventId }
        return saveEvents(events)
    }
    
    func loadEvents(for userId: String) -> [Event] {
        let allEvents = loadAllEvents()
        return allEvents.filter { $0.userId == userId }
    }
    
    func deleteAllEvents(for userId: String) -> Bool {
        var events = loadAllEvents()
        events.removeAll { $0.userId == userId }
        return saveEvents(events)
    }
    
    private func loadAllEvents() -> [Event] {
        guard let data = userDefaults.data(forKey: eventsKey),
              let events = try? JSONDecoder().decode([Event].self, from: data) else {
            return []
        }
        return events
    }
    
    private func saveEvents(_ events: [Event]) -> Bool {
        guard let data = try? JSONEncoder().encode(events) else {
            return false
        }
        userDefaults.set(data, forKey: eventsKey)
        return true
    }
    
    // MARK: - Data Management
    
    func clearAllData() {
        userDefaults.removeObject(forKey: usersKey)
        userDefaults.removeObject(forKey: invoicesKey)
        userDefaults.removeObject(forKey: eventsKey)
        userDefaults.removeObject(forKey: "currentUser")
    }
    
    func exportUserData(for userId: String) -> [String: Any] {
        let invoices = loadInvoices(for: userId)
        let events = loadEvents(for: userId)
        
        var exportData: [String: Any] = [:]
        
        if let invoicesData = try? JSONEncoder().encode(invoices),
           let invoicesJSON = try? JSONSerialization.jsonObject(with: invoicesData) {
            exportData["invoices"] = invoicesJSON
        }
        
        if let eventsData = try? JSONEncoder().encode(events),
           let eventsJSON = try? JSONSerialization.jsonObject(with: eventsData) {
            exportData["events"] = eventsJSON
        }
        
        exportData["exportDate"] = Date().timeIntervalSince1970
        
        return exportData
    }
    
    // MARK: - Statistics
    
    func getTotalUsers() -> Int {
        return loadAllUsers().count
    }
    
    func getTotalInvoices() -> Int {
        return loadAllInvoices().count
    }
    
    func getTotalEvents() -> Int {
        return loadAllEvents().count
    }
}
