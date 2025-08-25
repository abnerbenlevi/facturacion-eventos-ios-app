//
//  BillingFormView.swift
//  Billing & Events App
//
//  Invoice creation and editing form
//

import SwiftUI

struct BillingFormView: View {
    @EnvironmentObject var billingViewModel: BillingViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Form fields
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var amount: String = ""
    @State private var selectedType: InvoiceType = .income
    @State private var selectedStatus: InvoiceStatus = .pending
    
    // UI state
    @State private var showingSuccessAlert = false
    @FocusState private var focusedField: Field?
    
    // Edit mode
    let invoice: Invoice?
    
    enum Field {
        case title, description, amount
    }
    
    init(invoice: Invoice? = nil) {
        self.invoice = invoice
        
        // Initialize form with existing invoice data if editing
        if let invoice = invoice {
            _title = State(initialValue: invoice.title)
            _description = State(initialValue: invoice.description)
            _amount = State(initialValue: String(invoice.amount))
            _selectedType = State(initialValue: invoice.type)
            _selectedStatus = State(initialValue: invoice.status)
        }
    }
    
    var isEditing: Bool {
        invoice != nil
    }
    
    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !amount.isEmpty &&
        Double(amount) != nil &&
        Double(amount) ?? 0 > 0
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Basic Information Section
                Section {
                    // Title Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Título *")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        TextField("Ej: Consultoría, Compra de equipos...", text: $title)
                            .textFieldStyle(IOSFormTextFieldStyle())
                            .focused($focusedField, equals: .title)
                    }
                    .listRowInsets(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
                    .listRowBackground(Color.clear)
                    
                    // Description Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Descripción")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        TextField("Descripción detallada (opcional)", text: $description, axis: .vertical)
                            .textFieldStyle(IOSFormTextFieldStyle())
                            .lineLimit(3...6)
                            .focused($focusedField, equals: .description)
                    }
                    .listRowInsets(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
                    .listRowBackground(Color.clear)
                    
                    // Amount Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Monto *")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        HStack {
                            Text("$")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            TextField("0.00", text: $amount)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(IOSFormTextFieldStyle())
                                .focused($focusedField, equals: .amount)
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
                    .listRowBackground(Color.clear)
                    
                } header: {
                    Text("Información Básica")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .textCase(nil)
                }
                
                // Type and Status Section
                Section {
                    // Type Picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tipo de Factura")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 12) {
                            ForEach(InvoiceType.allCases, id: \.self) { type in
                                TypeSelectionCard(
                                    type: type,
                                    isSelected: selectedType == type
                                ) {
                                    selectedType = type
                                }
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
                    .listRowBackground(Color.clear)
                    
                    // Status Picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Estado")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Picker("Estado", selection: $selectedStatus) {
                            ForEach(InvoiceStatus.allCases, id: \.self) { status in
                                Text(status.displayName).tag(status)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .listRowInsets(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
                    .listRowBackground(Color.clear)
                    
                } header: {
                    Text("Categorización")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .textCase(nil)
                }
                
                // Preview Section
                if isFormValid {
                    Section {
                        InvoicePreviewCard(
                            title: title,
                            description: description,
                            amount: Double(amount) ?? 0,
                            type: selectedType,
                            status: selectedStatus
                        )
                        .listRowInsets(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
                        .listRowBackground(Color.clear)
                        
                    } header: {
                        Text("Vista Previa")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .textCase(nil)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .navigationTitle(isEditing ? "Editar Factura" : "Nueva Factura")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Actualizar" : "Guardar") {
                        saveInvoice()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .disabled(!isFormValid || billingViewModel.isLoading)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Listo") {
                        focusedField = nil
                    }
                    .foregroundColor(.blue)
                }
            }
            .alert("Error", isPresented: $billingViewModel.showAlert) {
                Button("OK") {
                    billingViewModel.clearError()
                }
            } message: {
                Text(billingViewModel.errorMessage)
            }
            .alert("¡Éxito!", isPresented: $showingSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text(isEditing ? "Factura actualizada correctamente" : "Factura creada correctamente")
            }
        }
    }
    
    private func saveInvoice() {
        guard let userId = userViewModel.currentUser?.id else { return }
        
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        let amountValue = Double(amount) ?? 0
        
        if isEditing, let existingInvoice = invoice {
            billingViewModel.updateInvoice(
                existingInvoice,
                title: cleanTitle,
                description: cleanDescription,
                amount: amountValue,
                type: selectedType,
                status: selectedStatus
            )
        } else {
            billingViewModel.addInvoice(
                title: cleanTitle,
                description: cleanDescription,
                amount: amountValue,
                type: selectedType,
                status: selectedStatus
            )
        }
        
        // Show success and dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if !billingViewModel.showAlert {
                showingSuccessAlert = true
            }
        }
    }
}

// MARK: - Supporting Views

struct IOSFormTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
    }
}

struct TypeSelectionCard: View {
    let type: InvoiceType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: type == .income ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                    .font(.title2)
                    .foregroundColor(type == .income ? .green : .red)
                
                Text(type.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color(.systemGray4), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct InvoicePreviewCard: View {
    let title: String
    let description: String
    let amount: Double
    let type: InvoiceType
    let status: InvoiceStatus
    
    var body: some View {
        HStack(spacing: 12) {
            // Type Indicator
            Circle()
                .fill(type == .income ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: type == .income ? "arrow.up" : "arrow.down")
                        .foregroundColor(type == .income ? .green : .red)
                        .font(.caption)
                        .fontWeight(.semibold)
                )
            
            // Invoice Details
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                if !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Text("Ahora")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Amount and Status
            VStack(alignment: .trailing, spacing: 4) {
                Text(formatCurrency(amount))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(type == .income ? .green : .red)
                
                StatusBadge(status: status)
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

#Preview {
    BillingFormView()
        .environmentObject(BillingViewModel())
        .environmentObject(UserViewModel())
}
