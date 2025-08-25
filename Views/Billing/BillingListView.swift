//
//  BillingListView.swift
//  Billing & Events App
//
//  Invoice list and management interface
//

import SwiftUI

struct BillingListView: View {
    @EnvironmentObject var billingViewModel: BillingViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    
    @State private var showingAddInvoice = false
    @State private var searchText = ""
    @State private var selectedFilter: InvoiceFilter = .all
    @State private var showingFilterSheet = false
    
    enum InvoiceFilter: String, CaseIterable {
        case all = "Todas"
        case income = "Ingresos"
        case expense = "Gastos"
        case pending = "Pendientes"
        case paid = "Pagadas"
        case overdue = "Vencidas"
    }
    
    var filteredInvoices: [Invoice] {
        var invoices = billingViewModel.invoices
        
        // Apply search filter
        if !searchText.isEmpty {
            invoices = billingViewModel.searchInvoices(query: searchText)
        }
        
        // Apply category filter
        switch selectedFilter {
        case .all:
            break
        case .income:
            invoices = invoices.filter { $0.type == .income }
        case .expense:
            invoices = invoices.filter { $0.type == .expense }
        case .pending:
            invoices = invoices.filter { $0.status == .pending }
        case .paid:
            invoices = invoices.filter { $0.status == .paid }
        case .overdue:
            invoices = invoices.filter { $0.status == .overdue }
        }
        
        return invoices
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Summary Header
                if !billingViewModel.invoices.isEmpty {
                    SummaryHeaderView()
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color(.systemGroupedBackground))
                }
                
                // Search and Filter Bar
                VStack(spacing: 12) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Buscar facturas...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                        
                        if !searchText.isEmpty {
                            Button("Limpiar") {
                                searchText = ""
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    // Filter Chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(InvoiceFilter.allCases, id: \.self) { filter in
                                FilterChip(
                                    title: filter.rawValue,
                                    isSelected: selectedFilter == filter
                                ) {
                                    selectedFilter = filter
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                
                // Invoice List
                if billingViewModel.isLoading {
                    Spacer()
                    ProgressView("Cargando facturas...")
                    Spacer()
                } else if filteredInvoices.isEmpty {
                    EmptyStateView(
                        icon: searchText.isEmpty ? "doc.text" : "magnifyingglass",
                        title: searchText.isEmpty ? "No hay facturas" : "Sin resultados",
                        subtitle: searchText.isEmpty ? "Crea tu primera factura para comenzar" : "Intenta con otros términos de búsqueda"
                    )
                } else {
                    List {
                        ForEach(filteredInvoices) { invoice in
                            NavigationLink(destination: BillingDetailView(invoice: invoice)) {
                                InvoiceRowView(invoice: invoice)
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: deleteInvoices)
                    }
                    .listStyle(PlainListStyle())
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("Facturación")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddInvoice = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingAddInvoice) {
                BillingFormView()
            }
            .alert("Error", isPresented: $billingViewModel.showAlert) {
                Button("OK") {
                    billingViewModel.clearError()
                }
            } message: {
                Text(billingViewModel.errorMessage)
            }
            .refreshable {
                if let userId = userViewModel.currentUser?.id {
                    billingViewModel.loadInvoices(for: userId)
                }
            }
        }
    }
    
    private func deleteInvoices(offsets: IndexSet) {
        for index in offsets {
            let invoice = filteredInvoices[index]
            billingViewModel.deleteInvoice(invoice)
        }
    }
}

// MARK: - Supporting Views

struct SummaryHeaderView: View {
    @EnvironmentObject var billingViewModel: BillingViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            SummaryCard(
                title: "Ingresos",
                amount: billingViewModel.totalIncome,
                color: .green,
                icon: "arrow.up.circle.fill"
            )
            
            SummaryCard(
                title: "Gastos",
                amount: billingViewModel.totalExpenses,
                color: .red,
                icon: "arrow.down.circle.fill"
            )
            
            SummaryCard(
                title: "Balance",
                amount: billingViewModel.netBalance,
                color: billingViewModel.netBalance >= 0 ? .green : .red,
                icon: billingViewModel.netBalance >= 0 ? "plus.circle.fill" : "minus.circle.fill"
            )
        }
    }
}

struct SummaryCard: View {
    let title: String
    let amount: Double
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.caption)
            
            Text(formatCurrency(amount))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct InvoiceRowView: View {
    let invoice: Invoice
    
    var body: some View {
        HStack(spacing: 12) {
            // Type Indicator
            Circle()
                .fill(invoice.type == .income ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: invoice.type == .income ? "arrow.up" : "arrow.down")
                        .foregroundColor(invoice.type == .income ? .green : .red)
                        .font(.caption)
                        .fontWeight(.semibold)
                )
            
            // Invoice Details
            VStack(alignment: .leading, spacing: 4) {
                Text(invoice.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                if !invoice.description.isEmpty {
                    Text(invoice.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Text(invoice.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Amount and Status
            VStack(alignment: .trailing, spacing: 4) {
                Text(invoice.formattedAmount)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(invoice.type == .income ? .green : .red)
                
                StatusBadge(status: invoice.status)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct StatusBadge: View {
    let status: InvoiceStatus
    
    var body: some View {
        Text(status.displayName)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(8)
    }
    
    private var backgroundColor: Color {
        switch status {
        case .pending:
            return Color.orange.opacity(0.2)
        case .paid:
            return Color.green.opacity(0.2)
        case .overdue:
            return Color.red.opacity(0.2)
        case .cancelled:
            return Color.gray.opacity(0.2)
        }
    }
    
    private var textColor: Color {
        switch status {
        case .pending:
            return .orange
        case .paid:
            return .green
        case .overdue:
            return .red
        case .cancelled:
            return .gray
        }
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    BillingListView()
        .environmentObject(BillingViewModel())
        .environmentObject(UserViewModel())
}
