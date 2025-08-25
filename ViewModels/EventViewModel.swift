//
//  EventViewModel.swift
//  Billing & Events App
//
//  Event management and notification logic
//

import Foundation
import Combine

class EventViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var showAlert: Bool = false
    
    private let dataService = DataService.shared
    private let notificationService = NotificationService.shared
    private var currentUserId: String = ""
    
    // MARK: - Computed Properties
    
    var upcomingEvents: [Event] {
        events.filter { $0.isUpcoming && !$0.isCompleted }
              .sorted { $0.eventDate < $1.eventDate }
    }
    
    var todayEvents: [Event] {
        events.filter { $0.isToday }
              .sorted { $0.eventDate < $1.eventDate }
    }
    
    var pastEvents: [Event] {
        events.filter { $0.isPast }
              .sorted { $0.eventDate > $1.eventDate }
    }
    
    var completedEvents: [Event] {
        events.filter { $0.isCompleted }
              .sorted { $0.eventDate > $1.eventDate }
    }
    
    var eventsWithReminders: [Event] {
        events.filter { $0.hasReminder }
    }
    
    // MARK: - Data Loading
    
    func loadEvents(for userId: String) {
        self.currentUserId = userId
        isLoading = true
        
        DispatchQueue.global(qos: .background).async {
            let loadedEvents = self.dataService.loadEvents(for: userId)
            
            DispatchQueue.main.async {
                self.events = loadedEvents.sorted { $0.eventDate < $1.eventDate }
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Event Management
    
    func addEvent(title: String, description: String, eventDate: Date, hasReminder: Bool, reminderMinutesBefore: Int = 15) {
        // Validation
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showError("El título es requerido")
            return
        }
        
        guard eventDate > Date() else {
            showError("La fecha del evento debe ser en el futuro")
            return
        }
        
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let newEvent = Event(
            userId: currentUserId,
            title: cleanTitle,
            description: cleanDescription,
            eventDate: eventDate,
            hasReminder: hasReminder,
            reminderMinutesBefore: reminderMinutesBefore
        )
        
        if dataService.saveEvent(newEvent) {
            // Schedule notification if reminder is enabled
            if hasReminder {
                notificationService.scheduleNotification(for: newEvent)
            }
            
            DispatchQueue.main.async {
                self.events.append(newEvent)
                self.events.sort { $0.eventDate < $1.eventDate }
            }
        } else {
            showError("Error al guardar el evento")
        }
    }
    
    func updateEvent(_ event: Event, title: String, description: String, eventDate: Date, hasReminder: Bool, reminderMinutesBefore: Int) {
        // Validation
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showError("El título es requerido")
            return
        }
        
        var updatedEvent = event
        updatedEvent.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedEvent.description = description.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedEvent.eventDate = eventDate
        updatedEvent.hasReminder = hasReminder
        updatedEvent.reminderMinutesBefore = reminderMinutesBefore
        updatedEvent.updatedAt = Date()
        
        if dataService.updateEvent(updatedEvent) {
            // Cancel existing notification
            notificationService.cancelNotification(for: event.id)
            
            // Schedule new notification if reminder is enabled
            if hasReminder && eventDate > Date() {
                notificationService.scheduleNotification(for: updatedEvent)
            }
            
            DispatchQueue.main.async {
                if let index = self.events.firstIndex(where: { $0.id == event.id }) {
                    self.events[index] = updatedEvent
                    self.events.sort { $0.eventDate < $1.eventDate }
                }
            }
        } else {
            showError("Error al actualizar el evento")
        }
    }
    
    func deleteEvent(_ event: Event) {
        if dataService.deleteEvent(event.id) {
            // Cancel notification if it exists
            notificationService.cancelNotification(for: event.id)
            
            DispatchQueue.main.async {
                self.events.removeAll { $0.id == event.id }
            }
        } else {
            showError("Error al eliminar el evento")
        }
    }
    
    func toggleEventCompletion(_ event: Event) {
        var updatedEvent = event
        
        if updatedEvent.isCompleted {
            updatedEvent.markAsIncomplete()
        } else {
            updatedEvent.markAsCompleted()
        }
        
        if dataService.updateEvent(updatedEvent) {
            DispatchQueue.main.async {
                if let index = self.events.firstIndex(where: { $0.id == event.id }) {
                    self.events[index] = updatedEvent
                }
            }
        } else {
            showError("Error al actualizar el estado del evento")
        }
    }
    
    func toggleEventReminder(_ event: Event) {
        var updatedEvent = event
        updatedEvent.hasReminder.toggle()
        updatedEvent.updatedAt = Date()
        
        if dataService.updateEvent(updatedEvent) {
            if updatedEvent.hasReminder && updatedEvent.eventDate > Date() {
                // Schedule notification
                notificationService.scheduleNotification(for: updatedEvent)
            } else {
                // Cancel notification
                notificationService.cancelNotification(for: event.id)
            }
            
            DispatchQueue.main.async {
                if let index = self.events.firstIndex(where: { $0.id == event.id }) {
                    self.events[index] = updatedEvent
                }
            }
        } else {
            showError("Error al actualizar el recordatorio")
        }
    }
    
    // MARK: - Filtering and Searching
    
    func filterEvents(by status: String) -> [Event] {
        switch status.lowercased() {
        case "upcoming":
            return upcomingEvents
        case "today":
            return todayEvents
        case "past":
            return pastEvents
        case "completed":
            return completedEvents
        default:
            return events
        }
    }
    
    func searchEvents(query: String) -> [Event] {
        guard !query.isEmpty else { return events }
        
        let lowercaseQuery = query.lowercased()
        return events.filter {
            $0.title.lowercased().contains(lowercaseQuery) ||
            $0.description.lowercased().contains(lowercaseQuery)
        }
    }
    
    func getEventsForDate(_ date: Date) -> [Event] {
        let calendar = Calendar.current
        return events.filter { calendar.isDate($0.eventDate, inSameDayAs: date) }
    }
    
    // MARK: - Statistics
    
    func getEventCountForMonth(_ date: Date = Date()) -> Int {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        
        return events.filter {
            calendar.component(.month, from: $0.eventDate) == month &&
            calendar.component(.year, from: $0.eventDate) == year
        }.count
    }
    
    func getCompletedEventCountForMonth(_ date: Date = Date()) -> Int {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        
        return events.filter {
            $0.isCompleted &&
            calendar.component(.month, from: $0.eventDate) == month &&
            calendar.component(.year, from: $0.eventDate) == year
        }.count
    }
    
    // MARK: - Notification Management
    
    func rescheduleAllNotifications() {
        // Cancel all existing notifications
        notificationService.cancelAllNotifications()
        
        // Reschedule notifications for upcoming events with reminders
        for event in eventsWithReminders {
            if event.eventDate > Date() {
                notificationService.scheduleNotification(for: event)
            }
        }
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
        loadEvents(for: currentUserId)
    }
}
