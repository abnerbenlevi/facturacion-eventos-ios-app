//
//  Invoice.swift
//  Billing & Events App
//
//  Invoice data model for billing management
//

import Foundation

struct Invoice: Identifiable, Codable {
    let id: String
    let userId: String
    var title: String
    var description: String
    var amount: Double
    var date: Date
    var status: InvoiceStatus
    var type: InvoiceType
    var createdAt: Date
    var updatedAt: Date
    
    init(userId: String, title: String, description: String = "", amount: Double, type: InvoiceType, status: InvoiceStatus = .pending) {
        self.id = UUID().uuidString
        self.userId = userId
        self.title = title
        self.description = description
        self.amount = amount
        self.date = Date()
        self.status = status
        self.type = type
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Invoice Status
enum InvoiceStatus: String, CaseIterable, Codable {
    case pending = "pending"
    case paid = "paid"
    case overdue = "overdue"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .pending:
            return "Pendiente"
        case .paid:
            return "Pagado"
        case .overdue:
            return "Vencido"
        case .cancelled:
            return "Cancelado"
        }
    }
    
    var color: String {
        switch self {
        case .pending:
            return "orange"
        case .paid:
            return "green"
        case .overdue:
            return "red"
        case .cancelled:
            return "gray"
        }
    }
}

// MARK: - Invoice Type
enum InvoiceType: String, CaseIterable, Codable {
    case income = "income"
    case expense = "expense"
    
    var displayName: String {
        switch self {
        case .income:
            return "Ingreso"
        case .expense:
            return "Gasto"
        }
    }
    
    var symbol: String {
        switch self {
        case .income:
            return "+"
        case .expense:
            return "-"
        }
    }
}

// MARK: - Invoice Extensions
extension Invoice {
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    mutating func updateStatus(_ newStatus: InvoiceStatus) {
        self.status = newStatus
        self.updatedAt = Date()
    }
}
