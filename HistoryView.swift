//
//  HistoryView.swift
//  FocusFlow
//
//  Created by Matthew Barghout on 11/29/25.
//

import SwiftUI

struct HistoryView: View {
    @Bindable var vm: FocusViewModel
    @State private var selectedFilter: FilterOption = .all
    
    enum FilterOption: String, CaseIterable {
        case all = "All"
        case today = "Today"
        case week = "This Week"
    }
    
    var filteredSessions: [FocusSession] {
        let calendar = Calendar.current
        switch selectedFilter {
        case .all:
            return vm.sessions
        case .today:
            return vm.sessions.filter { calendar.isDateInToday($0.date) }
        case .week:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
            return vm.sessions.filter { $0.date >= weekAgo }
        }
    }
    
    var groupedSessions: [(String, [FocusSession])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredSessions) { session in
            calendar.startOfDay(for: session.date)
        }
        
        return grouped.sorted { $0.key > $1.key }.map { date, sessions in
            let formatter = DateFormatter()
            if calendar.isDateInToday(date) {
                return ("Today", sessions.sorted { $0.date > $1.date })
            } else if calendar.isDateInYesterday(date) {
                return ("Yesterday", sessions.sorted { $0.date > $1.date })
            } else if calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear) {
                formatter.dateFormat = "EEEE"
                return (formatter.string(from: date), sessions.sorted { $0.date > $1.date })
            } else {
                formatter.dateStyle = .medium
                return (formatter.string(from: date), sessions.sorted { $0.date > $1.date })
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Filter Picker
            Picker("Filter", selection: $selectedFilter) {
                ForEach(FilterOption.allCases, id: \.self) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            if filteredSessions.isEmpty {
                ContentUnavailableView(
                    "No Sessions Yet",
                    systemImage: "clock.badge.questionmark",
                    description: Text("Start a focus session to see it here")
                )
            } else {
                List {
                    ForEach(groupedSessions, id: \.0) { day, sessions in
                        Section {
                            ForEach(sessions) { session in
                                SessionRow(session: session)
                            }
                            .onDelete { indexSet in
                                for index in indexSet {
                                    vm.deleteSession(sessions[index])
                                }
                            }
                        } header: {
                            Text(day)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("History")
    }
}

struct SessionRow: View {
    let session: FocusSession
    
    var body: some View {
        HStack(spacing: 12) {
            // Category Emoji
            Text(session.category.emoji)
                .font(.title2)
                .frame(width: 40, height: 40)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(session.category.rawValue)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(session.formattedDuration)
                        .font(.headline)
                        .foregroundStyle(.blue)
                }
                
                HStack {
                    if let note = session.note {
                        Text(note)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Text(session.date.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
