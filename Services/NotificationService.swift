//
//  NotificationService.swift
//  Billing & Events App
//
//  Local notification management service
//

import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private init() {}
    
    // MARK: - Permission Management
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
            
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    func checkPermissionStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
    
    // MARK: - Notification Scheduling
    
    func scheduleNotification(for event: Event) {
        // Check if the event date is in the future
        guard event.eventDate > Date() else {
            print("Cannot schedule notification for past event: \(event.title)")
            return
        }
        
        // Calculate reminder date
        let reminderDate = event.reminderDate
        
        // Check if reminder date is in the future
        guard reminderDate > Date() else {
            print("Reminder date is in the past for event: \(event.title)")
            return
        }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Recordatorio de Evento"
        content.body = "\(event.title) - \(event.formattedTimeOnly)"
        content.sound = .default
        content.badge = 1
        
        // Add custom data
        content.userInfo = [
            "eventId": event.id,
            "eventTitle": event.title,
            "eventDate": event.eventDate.timeIntervalSince1970
        ]
        
        // Create date components for trigger
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        
        // Create trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: event.id,
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification for event \(event.title): \(error.localizedDescription)")
            } else {
                print("Successfully scheduled notification for event: \(event.title) at \(reminderDate)")
            }
        }
    }
    
    func scheduleInvoiceReminder(for invoice: Invoice, reminderDate: Date) {
        // Check if the reminder date is in the future
        guard reminderDate > Date() else {
            print("Cannot schedule invoice reminder for past date")
            return
        }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Recordatorio de Factura"
        
        let typeText = invoice.type == .income ? "cobrar" : "pagar"
        content.body = "Recordatorio: \(typeText) \(invoice.title) - \(invoice.formattedAmount)"
        content.sound = .default
        content.badge = 1
        
        // Add custom data
        content.userInfo = [
            "invoiceId": invoice.id,
            "invoiceTitle": invoice.title,
            "invoiceAmount": invoice.amount,
            "invoiceType": invoice.type.rawValue
        ]
        
        // Create date components for trigger
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        
        // Create trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: "invoice_\(invoice.id)",
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling invoice reminder: \(error.localizedDescription)")
            } else {
                print("Successfully scheduled invoice reminder for: \(invoice.title)")
            }
        }
    }
    
    // MARK: - Notification Management
    
    func cancelNotification(for eventId: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [eventId])
        print("Cancelled notification for event ID: \(eventId)")
    }
    
    func cancelInvoiceNotification(for invoiceId: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["invoice_\(invoiceId)"])
        print("Cancelled invoice notification for ID: \(invoiceId)")
    }
    
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        print("Cancelled all pending notifications")
    }
    
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        notificationCenter.getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(requests)
            }
        }
    }
    
    // MARK: - Delivered Notifications
    
    func getDeliveredNotifications(completion: @escaping ([UNNotification]) -> Void) {
        notificationCenter.getDeliveredNotifications { notifications in
            DispatchQueue.main.async {
                completion(notifications)
            }
        }
    }
    
    func removeDeliveredNotifications(withIdentifiers identifiers: [String]) {
        notificationCenter.removeDeliveredNotifications(withIdentifiers: identifiers)
    }
    
    func removeAllDeliveredNotifications() {
        notificationCenter.removeAllDeliveredNotifications()
    }
    
    // MARK: - Utility Methods
    
    func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Notificación de Prueba"
        content.body = "Esta es una notificación de prueba de la app de Facturación y Eventos"
        content.sound = .default
        
        // Trigger in 5 seconds
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "test_notification",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling test notification: \(error.localizedDescription)")
            } else {
                print("Test notification scheduled successfully")
            }
        }
    }
    
    func printPendingNotifications() {
        getPendingNotifications { requests in
            print("Pending notifications count: \(requests.count)")
            for request in requests {
                print("- ID: \(request.identifier), Title: \(request.content.title)")
            }
        }
    }
    
    // MARK: - Batch Operations
    
    func rescheduleNotifications(for events: [Event]) {
        // Cancel existing notifications for these events
        let eventIds = events.map { $0.id }
        notificationCenter.removePendingNotificationRequests(withIdentifiers: eventIds)
        
        // Schedule new notifications
        for event in events {
            if event.hasReminder && event.eventDate > Date() {
                scheduleNotification(for: event)
            }
        }
    }
    
    func scheduleMultipleNotifications(for events: [Event]) {
        for event in events {
            if event.hasReminder && event.eventDate > Date() {
                scheduleNotification(for: event)
            }
        }
    }
}

// MARK: - Notification Categories and Actions
extension NotificationService {
    
    func setupNotificationCategories() {
        // Event reminder actions
        let markCompleteAction = UNNotificationAction(
            identifier: "MARK_COMPLETE",
            title: "Marcar como Completado",
            options: []
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE",
            title: "Recordar en 10 min",
            options: []
        )
        
        let eventCategory = UNNotificationCategory(
            identifier: "EVENT_REMINDER",
            actions: [markCompleteAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )
        
        // Invoice reminder actions
        let markPaidAction = UNNotificationAction(
            identifier: "MARK_PAID",
            title: "Marcar como Pagado",
            options: []
        )
        
        let invoiceCategory = UNNotificationCategory(
            identifier: "INVOICE_REMINDER",
            actions: [markPaidAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )
        
        // Register categories
        notificationCenter.setNotificationCategories([eventCategory, invoiceCategory])
    }
}
