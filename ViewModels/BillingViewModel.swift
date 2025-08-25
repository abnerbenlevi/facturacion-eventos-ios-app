//
//  BillingViewModel.swift
//  Billing & Events App
//
//  Billing and invoice management logic
//

import Foundation
import Combine

class BillingViewModel: ObservableObject {
    @Published var invoices: [Invoice] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var showAlert: Bool = false
    
    private let dataService = DataService.shared
    private var currentUserId: String = ""
    
    // MARK: - Computed Properties
    
    var totalIncome: Double {
        invoices.filter { $0.type == .income && $0.status == .paid }
                .reduce(0) { $0 + $1.amount }
    }
    
    var totalExpenses: Double {
        invoices.filter { $0.type == .expense && $0.status == .paid }
                .reduce(0) { $0 + $1.amount }
    }
    
    var netBalance: Double {
        return totalIncome - totalExpenses
    }
    
    var pendingInvoices: [Invoice] {
        invoices.filter { $0.status == .pending }
    }
    
    var paidInvoices: [Invoice] {
        invoices.filter { $0.status == .paid }
    }
    
    var overdueInvoices: [Invoice] {
        invoices.filter { $0.status == .overdue }
    }
    
    var incomeInvoices: [Invoice] {
        invoices.filter { $0.type == .income }
    }
    
    var expenseInvoices: [Invoice] {
        invoices.filter { $0.type == .expense }
    }
    
    // MARK: - Data Loading
    
    func loadInvoices(for userId: String) {
        self.currentUserId = userId
        isLoading = true
        
        DispatchQueue.global(qos: .background).async {
            let loadedInvoices = self.dataService.loadInvoices(for: userId)
            
            DispatchQueue.main.async {
                self.invoices = loadedInvoices.sorted { $0.date > $1.date }
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Invoice Management
    
    func addInvoice(title: String, description: String, amount: Double, type: InvoiceType, status: InvoiceStatus = .pending) {
        // Validation
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showError("El título es requerido")
            return
        }
        
        guard amount > 0 else {
            showError("El monto debe ser mayor a 0")
            return
        }
        
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let newInvoice = Invoice(
            userId: currentUserId,
            title: cleanTitle,
            description: cleanDescription,
            amount: amount,
            type: type,
            status: status
        )
        
        if dataService.saveInvoice(newInvoice) {
            DispatchQueue.main.async {
                self.invoices.insert(newInvoice, at: 0)
                self.invoices.sort { $0.date > $1.date }
            }
        } else {
            showError("Error al guardar la factura")
        }
    }
    
    func updateInvoice(_ invoice: Invoice, title: String, description: String, amount: Double, type: InvoiceType, status: InvoiceStatus) {
        // Validation
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showError("El título es requerido")
            return
        }
        
        guard amount > 0 else {
            showError("El monto debe ser mayor a 0")
            return
        }
        
        var updatedInvoice = invoice
        updatedInvoice.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedInvoice.description = description.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedInvoice.amount = amount
        updatedInvoice.type = type
        updatedInvoice.status = status
        updatedInvoice.updatedAt = Date()
        
        if dataService.updateInvoice(updatedInvoice) {
            DispatchQueue.main.async {
                if let index = self.invoices.firstIndex(where: { $0.id == invoice.id }) {
                    self.invoices[index] = updatedInvoice
                    self.invoices.sort { $0.date > $1.date }
                }
            }
        } else {
            showError("Error al actualizar la factura")
        }
    }
    
    func deleteInvoice(_ invoice: Invoice) {
        if dataService.deleteInvoice(invoice.id) {
            DispatchQueue.main.async {
                self.invoices.removeAll { $0.id == invoice.id }
            }
        } else {
            showError("Error al eliminar la factura")
        }
    }
    
    func updateInvoiceStatus(_ invoice: Invoice, status: InvoiceStatus) {
        var updatedInvoice = invoice
        updatedInvoice.updateStatus(status)
        
        if dataService.updateInvoice(updatedInvoice) {
            DispatchQueue.main.async {
                if let index = self.invoices.firstIndex(where: { $0.id == invoice.id }) {
                    self.invoices[index] = updatedInvoice
                }
            }
        } else {
            showError("Error al actualizar el estado de la factura")
        }
    }
    
    // MARK: - Filtering and Searching
    
    func filterInvoices(by status: InvoiceStatus) -> [Invoice] {
        return invoices.filter { $0.status == status }
    }
    
    func filterInvoices(by type: InvoiceType) -> [Invoice] {
        return invoices.filter { $0.type == type }
    }
    
    func searchInvoices(query: String) -> [Invoice] {
        guard !query.isEmpty else { return invoices }
        
        let lowercaseQuery = query.lowercased()
        return invoices.filter {
            $0.title.lowercased().contains(lowercaseQuery) ||
            $0.description.lowercased().contains(lowercaseQuery)
        }
    }
    
    // MARK: - Statistics
    
    func getMonthlyIncome(for date: Date = Date()) -> Double {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        
        return invoices.filter {
            $0.type == .income &&
            $0.status == .paid &&
            calendar.component(.month, from: $0.date) == month &&
            calendar.component(.year, from: $0.date) == year
        }.reduce(0) { $0 + $1.amount }
    }
    
    func getMonthlyExpenses(for date: Date = Date()) -> Double {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        
        return invoices.filter {
            $0.type == .expense &&
            $0.status == .paid &&
            calendar.component(.month, from: $0.date) == month &&
            calendar.component(.year, from: $0.date) == year
        }.reduce(0) { $0 + $1.amount }
    }
    
    // MARK: - Helper Methods
    
    private func showError(_ message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
            self.showAlert = true
        }
    }
    
    func clearError() {
        errorMessage = ""
        showAlert = false
    }
    
    // MARK: - Refresh Data
    
    func refreshData() {
        guard !currentUserId.isEmpty else { return }
        loadInvoices(for: currentUserId)
    }
}
