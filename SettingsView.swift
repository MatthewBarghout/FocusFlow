//
//  SettingsView.swift
//  FocusFlow
//
//  Created by Matthew Barghout on 11/29/25.
//


import SwiftUI

struct SettingsView: View {
    @Bindable var vm: FocusViewModel
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("dailyGoal") private var dailyGoal = 120.0 // minutes
    @State private var showingClearDataAlert = false
    
    var body: some View {
        Form {
            Section("Goals") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Daily Focus Goal")
                        Spacer()
                        Text("\(Int(dailyGoal)) min")
                            .foregroundStyle(.secondary)
                    }
                    
                    Slider(value: $dailyGoal, in: 30...480, step: 15)
                }
            }
            
            Section("Notifications") {
                Toggle("Enable Notifications", isOn: $notificationsEnabled)
                
                Toggle("Sound Effects", isOn: $soundEnabled)
            }
            
            Section("Data") {
                HStack {
                    Text("Total Sessions")
                    Spacer()
                    Text("\(vm.sessions.count)")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Total Focus Time")
                    Spacer()
                    Text(formatTotalTime(vm.totalFocusTime))
                        .foregroundStyle(.secondary)
                }
                
                Button("Clear All Data", role: .destructive) {
                    showingClearDataAlert = true
                }
            }
            
            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
                
                Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                
                Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)
            }
            
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "target")
                            .font(.largeTitle)
                            .foregroundStyle(.blue)
                        Text("FocusFlow")
                            .font(.headline)
                        Text("Stay focused, achieve more")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Settings")
        .alert("Clear All Data?", isPresented: $showingClearDataAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                vm.sessions.removeAll()
                vm.saveSessions()
            }
        } message: {
            Text("This will permanently delete all your focus sessions. This action cannot be undone.")
        }
    }
    
    private func formatTotalTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
