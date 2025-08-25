//
//  EventFormView.swift
//  Billing & Events App
//
//  Event creation and editing form
//

import SwiftUI

struct EventFormView: View {
    @EnvironmentObject var eventViewModel: EventViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Form fields
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var eventDate: Date = Date().addingTimeInterval(3600) // 1 hour from now
    @State private var hasReminder: Bool = true
    @State private var selectedReminderOption: ReminderOption = .fifteenMinutes
    
    // UI state
    @State private var showingSuccessAlert = false
    @FocusState private var focusedField: Field?
    
    // Edit mode
    let event: Event?
    
    enum Field {
        case title, description
    }
    
    init(event: Event? = nil) {
        self.event = event
        
        // Initialize form with existing event data if editing
        if let event = event {
            _title = State(initialValue: event.title)
            _description = State(initialValue: event.description)
            _eventDate = State(initialValue: event.eventDate)
            _hasReminder = State(initialValue: event.hasReminder)
            _selectedReminderOption = State(initialValue: ReminderOption(rawValue: event.reminderMinutesBefore) ?? .fifteenMinutes)
        }
    }
    
    var isEditing: Bool {
        event != nil
    }
    
    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        eventDate > Date()
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Basic Information Section
                Section {
                    // Title Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Título del Evento *")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        TextField("Ej: Reunión con cliente, Entrega de proyecto...", text: $title)
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
                        
                        TextField("Detalles adicionales del evento (opcional)", text: $description, axis: .vertical)
                            .textFieldStyle(IOSFormTextFieldStyle())
                            .lineLimit(3...6)
                            .focused($focusedField, equals: .description)
                    }
                    .listRowInsets(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
                    .listRowBackground(Color.clear)
                    
                } header: {
                    Text("Información del Evento")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .textCase(nil)
                }
                
                // Date and Time Section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Fecha y Hora *")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        DatePicker(
                            "Selecciona fecha y hora",
                            selection: $eventDate,
                            in: Date()...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(CompactDatePickerStyle())
                        .labelsHidden()
                        
                        // Date Preview
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.blue)
                                .font(.caption)
                            
                            Text(formatEventDate(eventDate))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 4)
                    }
                    .listRowInsets(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
                    .listRowBackground(Color.clear)
                    
                } header: {
                    Text("Programación")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .textCase(nil)
                }
                
                // Reminder Section
                Section {
                    // Reminder Toggle
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle(isOn: $hasReminder) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Activar Recordatorio")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text("Recibe una notificación antes del evento")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        
                        // Reminder Time Selection
                        if hasReminder {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Recordar")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                
                                Picker("Tiempo de recordatorio", selection: $selectedReminderOption) {
                                    ForEach(ReminderOption.allCases, id: \.self) { option in
                                        Text(option.displayName).tag(option)
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(height: 120)
                                
                                // Reminder Preview
                                HStack {
                                    Image(systemName: "bell")
                                        .foregroundColor(.orange)
                                        .font(.caption)
                                    
                                    Text("Notificación: \(formatReminderDate())")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
                    .listRowBackground(Color.clear)
                    
                } header: {
                    Text("Notificaciones")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .textCase(nil)
                }
                
                // Preview Section
                if isFormValid {
                    Section {
                        EventPreviewCard(
                            title: title,
                            description: description,
                            eventDate: eventDate,
                            hasReminder: hasReminder,
                            reminderMinutes: selectedReminderOption.rawValue
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
            .navigationTitle(isEditing ? "Editar Evento" : "Nuevo Evento")
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
                        saveEvent()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .disabled(!isFormValid || eventViewModel.isLoading)
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
            .alert("Error", isPresented: $eventViewModel.showAlert) {
                Button("OK") {
                    eventViewModel.clearError()
                }
            } message: {
                Text(eventViewModel.errorMessage)
            }
            .alert("¡Éxito!", isPresented: $showingSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text(isEditing ? "Evento actualizado correctamente" : "Evento creado correctamente")
            }
        }
    }
    
    private func saveEvent() {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if isEditing, let existingEvent = event {
            eventViewModel.updateEvent(
                existingEvent,
                title: cleanTitle,
                description: cleanDescription,
                eventDate: eventDate,
                hasReminder: hasReminder,
                reminderMinutesBefore: selectedReminderOption.rawValue
            )
        } else {
            eventViewModel.addEvent(
                title: cleanTitle,
                description: cleanDescription,
                eventDate: eventDate,
                hasReminder: hasReminder,
                reminderMinutesBefore: selectedReminderOption.rawValue
            )
        }
        
        // Show success and dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if !eventViewModel.showAlert {
                showingSuccessAlert = true
            }
        }
    }
    
    private func formatEventDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatReminderDate() -> String {
        let reminderDate = eventDate.addingTimeInterval(-Double(selectedReminderOption.rawValue * 60))
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: reminderDate)
    }
}

// MARK: - Supporting Views

struct EventPreviewCard: View {
    let title: String
    let description: String
    let eventDate: Date
    let hasReminder: Bool
    let reminderMinutes: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // Status Indicator
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                        .font(.caption)
                        .fontWeight(.semibold)
                )
            
            // Event Details
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
                
                HStack(spacing: 8) {
                    Text(formatDate(eventDate))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if hasReminder {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.orange)
                            .font(.caption2)
                    }
                }
            }
            
            Spacer()
            
            // Status
            VStack(alignment: .trailing, spacing: 4) {
                Text("Próximo")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    EventFormView()
        .environmentObject(EventViewModel())
        .environmentObject(UserViewModel())
}
