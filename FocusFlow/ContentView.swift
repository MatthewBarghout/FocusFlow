//
//  ContentView.swift
//  FocusFlow
//
//  Created by Matthew Barghout on 11/10/25.
//

import SwiftUI

struct ContentView: View {
    @State private var vm = FocusViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                TimerView(vm: vm)
            }
            .tabItem {
                Label("Focus", systemImage: "timer")
            }
            .tag(0)
            
            NavigationStack {
                HistoryView(vm: vm)
            }
            .tabItem {
                Label("History", systemImage: "clock.arrow.circlepath")
            }
            .tag(1)
            
            NavigationStack {
                StatsView(vm: vm)
            }
            .tabItem {
                Label("Stats", systemImage: "chart.bar.fill")
            }
            .tag(2)
            
            NavigationStack {
                SettingsView(vm: vm)
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(3)
        }
        .tint(.blue)
    }
}

#Preview {
    ContentView()
}
