//
//  StatsView.swift
//  FocusFlow
//
//  Created by Matthew Barghout on 11/29/25.
//

import SwiftUI
import Charts

struct StatsView: View {
    @Bindable var vm: FocusViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Summary Cards
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    StatCard(
                        title: "Today",
                        value: formatTimeShort(vm.todayFocusTime),
                        icon: "sun.max.fill",
                        color: .orange
                    )
                    
                    StatCard(
                        title: "This Week",
                        value: formatTimeShort(vm.weekFocusTime),
                        icon: "calendar",
                        color: .blue
                    )
                    
                    StatCard(
                        title: "Total Sessions",
                        value: "\(vm.sessions.count)",
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                    
                    StatCard(
                        title: "Avg Session",
                        value: formatTimeShort(vm.averageSessionDuration),
                        icon: "chart.bar.fill",
                        color: .purple
                    )
                }
                .padding(.horizontal)
                
                // Category Breakdown
                if !vm.sessions.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Focus by Category")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            ForEach(vm.sessionsByCategory(), id: \.0) { category, duration in
                                CategoryBar(
                                    category: category,
                                    duration: duration,
                                    total: vm.totalFocusTime
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 8)
                    .padding(.horizontal)
                    
                    // Daily Chart
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Daily Focus Time (Last 7 Days)")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        let last7Days = vm.sessionsByDay().prefix(7)
                        
                        if !last7Days.isEmpty {
                            Chart {
                                ForEach(Array(last7Days), id: \.0) { date, duration in
                                    BarMark(
                                        x: .value("Day", date, unit: .day),
                                        y: .value("Minutes", duration / 60)
                                    )
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.blue, .purple],
                                            startPoint: .bottom,
                                            endPoint: .top
                                        )
                                    )
                                    .cornerRadius(8)
                                }
                            }
                            .frame(height: 200)
                            .chartXAxis {
                                AxisMarks(values: .stride(by: .day)) { value in
                                    if let date = value.as(Date.self) {
                                        AxisValueLabel {
                                            Text(date, format: .dateTime.weekday(.narrow))
                                        }
                                    }
                                }
                            }
                            .chartYAxis {
                                AxisMarks { value in
                                    AxisValueLabel {
                                        if let minutes = value.as(Double.self) {
                                            Text("\(Int(minutes))m")
                                        }
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                    .padding(.vertical)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 8)
                    .padding(.horizontal)
                    
                    // Insights
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Insights")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            if let topCategory = vm.sessionsByCategory().first {
                                InsightCard(
                                    icon: "star.fill",
                                    color: .yellow,
                                    title: "Top Category",
                                    description: "\(topCategory.0.emoji) \(topCategory.0.rawValue) with \(formatTimeShort(topCategory.1))"
                                )
                            }
                            
                            if vm.sessions.count >= 3 {
                                let streak = calculateStreak()
                                if streak > 1 {
                                    InsightCard(
                                        icon: "flame.fill",
                                        color: .orange,
                                        title: "Focus Streak",
                                        description: "\(streak) days in a row!"
                                    )
                                }
                            }
                            
                            let todaySessions = vm.sessionsToday().count
                            if todaySessions > 0 {
                                InsightCard(
                                    icon: "checkmark.seal.fill",
                                    color: .green,
                                    title: "Today's Progress",
                                    description: "Completed \(todaySessions) session\(todaySessions == 1 ? "" : "s")"
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Statistics")
        .background(Color(.systemGroupedBackground))
    }
    
    private func calculateStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        while true {
            let hasSessions = vm.sessions.contains { session in
                calendar.isDate(session.date, inSameDayAs: currentDate)
            }
            
            if hasSessions {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            } else {
                break
            }
        }
        
        return streak
    }
    
    private func formatTimeShort(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Spacer()
            }
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8)
    }
}

struct CategoryBar: View {
    let category: SessionCategory
    let duration: TimeInterval
    let total: TimeInterval
    
    var percentage: Double {
        total > 0 ? duration / total : 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                HStack(spacing: 6) {
                    Text(category.emoji)
                    Text(category.rawValue)
                        .font(.subheadline)
                }
                
                Spacer()
                
                Text("\(Int(percentage * 100))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(formatTime(duration))
                    .font(.caption)
                    .fontWeight(.medium)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * percentage)
                }
            }
            .frame(height: 8)
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct InsightCard: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.2))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4)
    }
}
