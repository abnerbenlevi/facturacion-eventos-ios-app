//
//  BillingApp.swift
//  Billing & Events App
//
//  Created on iOS Native Development
//  Copyright © 2024. All rights reserved.
//

import SwiftUI
import UserNotifications

@main
struct BillingApp: App {
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var billingViewModel = BillingViewModel()
    @StateObject private var eventViewModel = EventViewModel()
    
    init() {
        // Request notification permissions on app launch
        requestNotificationPermissions()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userViewModel)
                .environmentObject(billingViewModel)
                .environmentObject(eventViewModel)
                .onAppear {
                    // Load user data on app start
                    userViewModel.loadCurrentUser()
                    
                    // Load data for current user if logged in
                    if userViewModel.isLoggedIn {
                        billingViewModel.loadInvoices(for: userViewModel.currentUser?.id ?? "")
                        eventViewModel.loadEvents(for: userViewModel.currentUser?.id ?? "")
                    }
                }
        }
    }
    
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permissions granted")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
}
