//
//  BillingDetailView.swift
//  Billing & Events App
//
//  Invoice detail and editing interface
//

import SwiftUI

struct BillingDetailView: View {
    @EnvironmentObject var billingViewModel: BillingViewModel
    @Environment(\.dismiss) private var dismiss
    
    let invoice: Invoice
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Card
                VStack(spacing: 16) {
                    // Type and Amount
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(invoice.type.displayName)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            Text(invoice.formattedAmount)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(invoice.type == .income ? .green : .red)
                        }
                        
                        Spacer()
                        
                        // Status Badge
                        VStack(alignment: .trailing, spacing: 4) {
                            StatusBadge(status: invoice.status)
                            
                            Text(invoice.formattedDate)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    // Title and Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text(invoice.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        if !invoice.description.isEmpty {
                            Text(invoice.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(20)
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                
                // Details Section
                VStack(spacing: 16) {
                    DetailRow(title: "ID", value: invoice.id)
                    DetailRow(title: "Tipo", value: invoice.type.displayName)
                    DetailRow(title: "Estado", value: invoice.status.displayName)
                    DetailRow(title: "Fecha", value: invoice.formattedDate)
                    DetailRow(title: "Creado", value: formatDate(invoice.createdAt))
                    
                    if invoice.updatedAt != invoice.createdAt {
                        DetailRow(title: "Actualizado", value: formatDate(invoice.updatedAt))
                    }
                }
                .padding(20)
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                
                // Quick Actions
                VStack(spacing: 12) {
                    Text("Acciones Rápidas")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 8) {
                        // Status Change Buttons
                        if invoice.status != .paid {
                            ActionButton(
                                title: "Marcar como Pagado",
                                icon: "checkmark.circle.fill",
                                color: .green
                            ) {
                                billingViewModel.updateInvoiceStatus(invoice, status: .paid)
                            }
                        }
                        
                        if invoice.status != .pending {
                            ActionButton(
                                title: "Marcar como Pendiente",
                                icon: "clock.circle.fill",
                                color: .orange
                            ) {
                                billingViewModel.updateInvoiceStatus(invoice, status: .pending)
                            }
                        }
                        
                        if invoice.status != .cancelled {
                            ActionButton(
                                title: "Cancelar Factura",
                                icon: "xmark.circle.fill",
                                color: .gray
                            ) {
                                billingViewModel.updateInvoiceStatus(invoice, status: .cancelled)
                            }
                        }
                    }
                }
                .padding(20)
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
        .navigationTitle("Detalle de Factura")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        showingEditSheet = true
                    }) {
                        Label("Editar", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: {
                        showingDeleteAlert = true
                    }) {
                        Label("Eliminar", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.blue)
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            BillingFormView(invoice: invoice)
        }
        .alert("Eliminar Factura", isPresented: $showingDeleteAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Eliminar", role: .destructive) {
                billingViewModel.deleteInvoice(invoice)
                dismiss()
            }
        } message: {
            Text("¿Estás seguro de que quieres eliminar esta factura? Esta acción no se puede deshacer.")
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                
                Text(title)
                    .fontWeight(.medium)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(color.opacity(0.1))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationStack {
        BillingDetailView(
            invoice: Invoice(
                userId: "test",
                title: "Consultoría Web",
                description: "Desarrollo de sitio web corporativo",
                amount: 2500.0,
                type: .income,
                status: .pending
            )
        )
        .environmentObject(BillingViewModel())
    }
}
