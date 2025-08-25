//
//  EventsListView.swift
//  Billing & Events App
//
//  Events list and management interface
//

import SwiftUI

struct EventsListView: View {
    @EnvironmentObject var eventViewModel: EventViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    
    @State private var showingAddEvent = false
    @State private var searchText = ""
    @State private var selectedFilter: EventFilter = .upcoming
    
    enum EventFilter: String, CaseIterable {
        case all = "Todos"
        case upcoming = "Próximos"
        case today = "Hoy"
        case past = "Pasados"
        case completed = "Completados"
    }
    
    var filteredEvents: [Event] {
        var events: [Event]
        
        // Apply category filter first
        switch selectedFilter {
        case .all:
            events = eventViewModel.events
        case .upcoming:
            events = eventViewModel.upcomingEvents
        case .today:
            events = eventViewModel.todayEvents
        case .past:
            events = eventViewModel.pastEvents
        case .completed:
            events = eventViewModel.completedEvents
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            let lowercaseQuery = searchText.lowercased()
            events = events.filter {
                $0.title.lowercased().contains(lowercaseQuery) ||
                $0.description.lowercased().contains(lowercaseQuery)
            }
        }
        
        return events
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Summary Header
                if !eventViewModel.events.isEmpty {
                    EventSummaryHeaderView()
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color(.systemGroupedBackground))
                }
                
                // Search and Filter Bar
                VStack(spacing: 12) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Buscar eventos...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                        
                        if !searchText.isEmpty {
                            Button("Limpiar") {
                                searchText = ""
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    // Filter Chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(EventFilter.allCases, id: \.self) { filter in
                                FilterChip(
                                    title: filter.rawValue,
                                    isSelected: selectedFilter == filter,
                                    count: getFilterCount(filter)
                                ) {
                                    selectedFilter = filter
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                
                // Events List
                if eventViewModel.isLoading {
                    Spacer()
                    ProgressView("Cargando eventos...")
                    Spacer()
                } else if filteredEvents.isEmpty {
                    EmptyEventsStateView(
                        hasSearch: !searchText.isEmpty,
                        filter: selectedFilter
                    )
                } else {
                    List {
                        ForEach(filteredEvents) { event in
                            NavigationLink(destination: EventDetailView(event: event)) {
                                EventRowView(event: event)
                                    .onTapGesture {
                                        // Handle tap if needed
                                    }
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: deleteEvents)
                    }
                    .listStyle(PlainListStyle())
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("Eventos")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddEvent = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingAddEvent) {
                EventFormView()
            }
            .alert("Error", isPresented: $eventViewModel.showAlert) {
                Button("OK") {
                    eventViewModel.clearError()
                }
            } message: {
                Text(eventViewModel.errorMessage)
            }
            .refreshable {
                if let userId = userViewModel.currentUser?.id {
                    eventViewModel.loadEvents(for: userId)
                }
            }
        }
    }
    
    private func deleteEvents(offsets: IndexSet) {
        for index in offsets {
            let event = filteredEvents[index]
            eventViewModel.deleteEvent(event)
        }
    }
    
    private func getFilterCount(_ filter: EventFilter) -> Int {
        switch filter {
        case .all:
            return eventViewModel.events.count
        case .upcoming:
            return eventViewModel.upcomingEvents.count
        case .today:
            return eventViewModel.todayEvents.count
        case .past:
            return eventViewModel.pastEvents.count
        case .completed:
            return eventViewModel.completedEvents.count
        }
    }
}

// MARK: - Supporting Views

struct EventSummaryHeaderView: View {
    @EnvironmentObject var eventViewModel: EventViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            EventSummaryCard(
                title: "Próximos",
                count: eventViewModel.upcomingEvents.count,
                color: .blue,
                icon: "calendar.circle.fill"
            )
            
            EventSummaryCard(
                title: "Hoy",
                count: eventViewModel.todayEvents.count,
                color: .orange,
                icon: "clock.circle.fill"
            )
            
            EventSummaryCard(
                title: "Completados",
                count: eventViewModel.completedEvents.count,
                color: .green,
                icon: "checkmark.circle.fill"
            )
        }
    }
}

struct EventSummaryCard: View {
    let title: String
    let count: Int
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.caption)
            
            Text("\(count)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                
                if count > 0 {
                    Text("(\(count))")
                        .font(.caption2)
                        .opacity(0.7)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EventRowView: View {
    @EnvironmentObject var eventViewModel: EventViewModel
    let event: Event
    
    var body: some View {
        HStack(spacing: 12) {
            // Status Indicator
            Circle()
                .fill(statusColor.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: statusIcon)
                        .foregroundColor(statusColor)
                        .font(.caption)
                        .fontWeight(.semibold)
                )
            
            // Event Details
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .strikethrough(event.isCompleted)
                
                if !event.description.isEmpty {
                    Text(event.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                HStack(spacing: 8) {
                    Text(event.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if event.hasReminder {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.orange)
                            .font(.caption2)
                    }
                }
            }
            
            Spacer()
            
            // Actions and Status
            VStack(alignment: .trailing, spacing: 4) {
                Text(event.statusText)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .cornerRadius(8)
                
                // Quick Complete Button
                if !event.isCompleted && !event.isPast {
                    Button(action: {
                        eventViewModel.toggleEventCompletion(event)
                    }) {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .opacity(event.isCompleted ? 0.7 : 1.0)
    }
    
    private var statusColor: Color {
        if event.isCompleted {
            return .green
        } else if event.isPast {
            return .red
        } else if event.isToday {
            return .orange
        } else {
            return .blue
        }
    }
    
    private var statusIcon: String {
        if event.isCompleted {
            return "checkmark"
        } else if event.isPast {
            return "exclamationmark"
        } else if event.isToday {
            return "clock"
        } else {
            return "calendar"
        }
    }
}

struct EmptyEventsStateView: View {
    let hasSearch: Bool
    let filter: EventsListView.EventFilter
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: hasSearch ? "magnifyingglass" : "calendar")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            VStack(spacing: 4) {
                Text(emptyTitle)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(emptySubtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    private var emptyTitle: String {
        if hasSearch {
            return "Sin resultados"
        }
        
        switch filter {
        case .all:
            return "No hay eventos"
        case .upcoming:
            return "No hay eventos próximos"
        case .today:
            return "No hay eventos hoy"
        case .past:
            return "No hay eventos pasados"
        case .completed:
            return "No hay eventos completados"
        }
    }
    
    private var emptySubtitle: String {
        if hasSearch {
            return "Intenta con otros términos de búsqueda"
        }
        
        switch filter {
        case .all:
            return "Crea tu primer evento para comenzar"
        case .upcoming:
            return "Programa eventos futuros para mantenerte organizado"
        case .today:
            return "No tienes eventos programados para hoy"
        case .past:
            return "Los eventos pasados aparecerán aquí"
        case .completed:
            return "Los eventos completados aparecerán aquí"
        }
    }
}

// MARK: - Event Detail View Placeholder
struct EventDetailView: View {
    let event: Event
    
    var body: some View {
        Text("Event Detail View - \(event.title)")
            .navigationTitle("Detalle del Evento")
    }
}

#Preview {
    EventsListView()
        .environmentObject(EventViewModel())
        .environmentObject(UserViewModel())
}
