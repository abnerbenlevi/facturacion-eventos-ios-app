//
//  DashboardView.swift
//  Billing & Events App
//
//  Main dashboard with tab navigation
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var billingViewModel: BillingViewModel
    @EnvironmentObject var eventViewModel: EventViewModel
    
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("Inicio")
                }
                .tag(0)
            
            // Billing Tab
            BillingListView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "doc.text.fill" : "doc.text")
                    Text("Facturación")
                }
                .tag(1)
            
            // Events Tab
            EventsListView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "calendar.circle.fill" : "calendar.circle")
                    Text("Eventos")
                }
                .tag(2)
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "person.fill" : "person")
                    Text("Perfil")
                }
                .tag(3)
        }
        .accentColor(.blue)
        .onAppear {
            // Load data when dashboard appears
            if let userId = userViewModel.currentUser?.id {
                billingViewModel.loadInvoices(for: userId)
                eventViewModel.loadEvents(for: userId)
            }
        }
    }
}

// MARK: - Home View
struct HomeView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var billingViewModel: BillingViewModel
    @EnvironmentObject var eventViewModel: EventViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("¡Hola, \(userViewModel.currentUser?.displayName ?? "Usuario")!")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                Text("Aquí tienes un resumen de tu actividad")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Profile Image Placeholder
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Text(String(userViewModel.currentUser?.name.prefix(1) ?? "U"))
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Financial Summary Cards
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            // Total Income Card
                            FinancialCard(
                                title: "Ingresos",
                                amount: billingViewModel.totalIncome,
                                color: .green,
                                icon: "arrow.up.circle.fill"
                            )
                            
                            // Total Expenses Card
                            FinancialCard(
                                title: "Gastos",
                                amount: billingViewModel.totalExpenses,
                                color: .red,
                                icon: "arrow.down.circle.fill"
                            )
                        }
                        
                        // Net Balance Card
                        HStack {
                            FinancialCard(
                                title: "Balance Neto",
                                amount: billingViewModel.netBalance,
                                color: billingViewModel.netBalance >= 0 ? .green : .red,
                                icon: billingViewModel.netBalance >= 0 ? "plus.circle.fill" : "minus.circle.fill",
                                isWide: true
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Quick Actions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Acciones Rápidas")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 20)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                QuickActionCard(
                                    title: "Nueva Factura",
                                    icon: "plus.circle.fill",
                                    color: .blue
                                ) {
                                    // Navigate to new invoice
                                }
                                
                                QuickActionCard(
                                    title: "Nuevo Evento",
                                    icon: "calendar.badge.plus",
                                    color: .orange
                                ) {
                                    // Navigate to new event
                                }
                                
                                QuickActionCard(
                                    title: "Ver Reportes",
                                    icon: "chart.bar.fill",
                                    color: .purple
                                ) {
                                    // Navigate to reports
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    // Recent Activity
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Actividad Reciente")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            // Recent Invoices
                            if !billingViewModel.invoices.isEmpty {
                                ForEach(Array(billingViewModel.invoices.prefix(3))) { invoice in
                                    RecentInvoiceRow(invoice: invoice)
                                }
                            }
                            
                            // Recent Events
                            if !eventViewModel.upcomingEvents.isEmpty {
                                ForEach(Array(eventViewModel.upcomingEvents.prefix(3))) { event in
                                    RecentEventRow(event: event)
                                }
                            }
                            
                            if billingViewModel.invoices.isEmpty && eventViewModel.events.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "tray")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                    
                                    Text("No hay actividad reciente")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
            .refreshable {
                if let userId = userViewModel.currentUser?.id {
                    billingViewModel.loadInvoices(for: userId)
                    eventViewModel.loadEvents(for: userId)
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct FinancialCard: View {
    let title: String
    let amount: Double
    let color: Color
    let icon: String
    var isWide: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(formatCurrency(amount))
                    .font(isWide ? .title2 : .headline)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 80, height: 80)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RecentInvoiceRow: View {
    let invoice: Invoice
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color(invoice.type == .income ? .green : .red).opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: invoice.type == .income ? "arrow.up" : "arrow.down")
                        .foregroundColor(invoice.type == .income ? .green : .red)
                        .font(.caption)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(invoice.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(invoice.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(invoice.formattedAmount)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(invoice.type == .income ? .green : .red)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
}

struct RecentEventRow: View {
    let event: Event
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                        .font(.caption)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(event.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if event.hasReminder {
                Image(systemName: "bell.fill")
                    .foregroundColor(.orange)
                    .font(.caption)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
}

#Preview {
    DashboardView()
        .environmentObject(UserViewModel())
        .environmentObject(BillingViewModel())
        .environmentObject(EventViewModel())
}
