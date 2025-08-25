//
//  Event.swift
//  Billing & Events App
//
//  Event data model for event management and notifications
//

import Foundation

struct Event: Identifiable, Codable {
    let id: String
    let userId: String
    var title: String
    var description: String
    var eventDate: Date
    var hasReminder: Bool
    var reminderMinutesBefore: Int
    var isCompleted: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(userId: String, title: String, description: String = "", eventDate: Date, hasReminder: Bool = false, reminderMinutesBefore: Int = 15) {
        self.id = UUID().uuidString
        self.userId = userId
        self.title = title
        self.description = description
        self.eventDate = eventDate
        self.hasReminder = hasReminder
        self.reminderMinutesBefore = reminderMinutesBefore
        self.isCompleted = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Event Extensions
extension Event {
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: eventDate)
    }
    
    var formattedDateOnly: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: eventDate)
    }
    
    var formattedTimeOnly: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: eventDate)
    }
    
    var isUpcoming: Bool {
        return eventDate > Date()
    }
    
    var isPast: Bool {
        return eventDate < Date()
    }
    
    var isToday: Bool {
        return Calendar.current.isDateInToday(eventDate)
    }
    
    var reminderDate: Date {
        return eventDate.addingTimeInterval(-Double(reminderMinutesBefore * 60))
    }
    
    var statusText: String {
        if isCompleted {
            return "Completado"
        } else if isPast {
            return "Vencido"
        } else if isToday {
            return "Hoy"
        } else {
            return "Próximo"
        }
    }
    
    var statusColor: String {
        if isCompleted {
            return "green"
        } else if isPast && !isCompleted {
            return "red"
        } else if isToday {
            return "orange"
        } else {
            return "blue"
        }
    }
    
    mutating func markAsCompleted() {
        self.isCompleted = true
        self.updatedAt = Date()
    }
    
    mutating func markAsIncomplete() {
        self.isCompleted = false
        self.updatedAt = Date()
    }
}

// MARK: - Reminder Options
enum ReminderOption: Int, CaseIterable {
    case fiveMinutes = 5
    case fifteenMinutes = 15
    case thirtyMinutes = 30
    case oneHour = 60
    case twoHours = 120
    case oneDay = 1440
    
    var displayName: String {
        switch self {
        case .fiveMinutes:
            return "5 minutos antes"
        case .fifteenMinutes:
            return "15 minutos antes"
        case .thirtyMinutes:
            return "30 minutos antes"
        case .oneHour:
            return "1 hora antes"
        case .twoHours:
            return "2 horas antes"
        case .oneDay:
            return "1 día antes"
        }
    }
}
