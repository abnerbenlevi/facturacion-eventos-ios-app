//
//  ContentView.swift
//  Billing & Events App
//
//  Main navigation controller for the app
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        Group {
            if userViewModel.isLoggedIn {
                DashboardView()
            } else {
                LoginView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: userViewModel.isLoggedIn)
    }
}

#Preview {
    ContentView()
        .environmentObject(UserViewModel())
        .environmentObject(BillingViewModel())
        .environmentObject(EventViewModel())
}
