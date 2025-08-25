//
//  ProfileView.swift
//  Billing & Events App
//
//  User profile and settings interface
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var billingViewModel: BillingViewModel
    @EnvironmentObject var eventViewModel: EventViewModel
    
    @State private var showingEditProfile = false
    @State private var showingLogoutAlert = false
    @State private var showingDeleteAccountAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        // Profile Image
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text(String(userViewModel.currentUser?.name.prefix(1) ?? "U"))
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                        
                        // User Info
                        VStack(spacing: 4) {
                            Text(userViewModel.currentUser?.displayName ?? "Usuario")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text(userViewModel.currentUser?.email ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        // Edit Profile Button
                        Button(action: {
                            showingEditProfile = true
                        }) {
                            Text("Editar Perfil")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(20)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Statistics Cards
                    VStack(spacing: 16) {
                        Text("Resumen de Actividad")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 16) {
                            StatCard(
                                title: "Facturas",
                                value: "\(billingViewModel.invoices.count)",
                                subtitle: "Total creadas",
                                color: .blue,
                                icon: "doc.text.fill"
                            )
                            
                            StatCard(
                                title: "Eventos",
                                value: "\(eventViewModel.events.count)",
                                subtitle: "Total programados",
                                color: .orange,
                                icon: "calendar.circle.fill"
                            )
                        }
                        
                        HStack(spacing: 16) {
                            StatCard(
                                title: "Balance",
                                value: formatCurrency(billingViewModel.netBalance),
                                subtitle: "Neto actual",
                                color: billingViewModel.netBalance >= 0 ? .green : .red,
                                icon: billingViewModel.netBalance >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill"
                            )
                            
                            StatCard(
                                title: "Próximos",
                                value: "\(eventViewModel.upcomingEvents.count)",
                                subtitle: "Eventos pendientes",
                                color: .purple,
                                icon: "clock.circle.fill"
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Settings Section
                    VStack(spacing: 16) {
                        Text("Configuración")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 0) {
                            SettingsRow(
                                title: "Notificaciones",
                                subtitle: "Gestionar recordatorios",
                                icon: "bell.fill",
                                color: .orange
                            ) {
                                // Handle notifications settings
                            }
                            
                            Divider()
                                .padding(.leading, 60)
                            
                            SettingsRow(
                                title: "Exportar Datos",
                                subtitle: "Descargar información",
                                icon: "square.and.arrow.up.fill",
                                color: .blue
                            ) {
                                exportUserData()
                            }
                            
                            Divider()
                                .padding(.leading, 60)
                            
                            SettingsRow(
                                title: "Ayuda y Soporte",
                                subtitle: "Obtener asistencia",
                                icon: "questionmark.circle.fill",
                                color: .green
                            ) {
                                // Handle help
                            }
                            
                            Divider()
                                .padding(.leading, 60)
                            
                            SettingsRow(
                                title: "Acerca de",
                                subtitle: "Información de la app",
                                icon: "info.circle.fill",
                                color: .gray
                            ) {
                                // Handle about
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    
                    // Account Actions
                    VStack(spacing: 12) {
                        // Logout Button
                        Button(action: {
                            showingLogoutAlert = true
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundColor(.red)
                                
                                Text("Cerrar Sesión")
                                    .fontWeight(.medium)
                                    .foregroundColor(.red)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Delete Account Button
                        Button(action: {
                            showingDeleteAccountAlert = true
                        }) {
                            HStack {
                                Image(systemName: "trash.fill")
                                    .foregroundColor(.red)
                                
                                Text("Eliminar Cuenta")
                                    .fontWeight(.medium)
                                    .foregroundColor(.red)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 20)
                    
                    // App Version
                    VStack(spacing: 4) {
                        Text("Facturación & Eventos")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Versión 1.0.0")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
            }
            .alert("Cerrar Sesión", isPresented: $showingLogoutAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Cerrar Sesión", role: .destructive) {
                    userViewModel.logout()
                }
            } message: {
                Text("¿Estás seguro de que quieres cerrar sesión?")
            }
            .alert("Eliminar Cuenta", isPresented: $showingDeleteAccountAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Eliminar", role: .destructive) {
                    deleteAccount()
                }
            } message: {
                Text("Esta acción eliminará permanentemente tu cuenta y todos tus datos. Esta acción no se puede deshacer.")
            }
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
    
    private func exportUserData() {
        guard let userId = userViewModel.currentUser?.id else { return }
        
        let dataService = DataService.shared
        let exportData = dataService.exportUserData(for: userId)
        
        // In a real app, you would present a share sheet or save to files
        print("Export data: \(exportData)")
        
        // For now, just show an alert
        // You could implement actual file export here
    }
    
    private func deleteAccount() {
        guard let userId = userViewModel.currentUser?.id else { return }
        
        let dataService = DataService.shared
        if dataService.deleteUser(userId) {
            userViewModel.logout()
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            
            VStack(spacing: 2) {
                Text(value)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct SettingsRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: icon)
                            .foregroundColor(color)
                            .font(.caption)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Edit Profile View
struct EditProfileView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var email: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Nombre completo", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                } header: {
                    Text("Información Personal")
                }
            }
            .navigationTitle("Editar Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        userViewModel.updateUserProfile(name: name, email: email)
                        dismiss()
                    }
                    .disabled(name.isEmpty || email.isEmpty)
                }
            }
            .onAppear {
                name = userViewModel.currentUser?.name ?? ""
                email = userViewModel.currentUser?.email ?? ""
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(UserViewModel())
        .environmentObject(BillingViewModel())
        .environmentObject(EventViewModel())
}
