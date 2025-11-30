//
//  TimerView.swift
//  FocusFlow
//
//  Created by Matthew Barghout on 11/20/25.
//

import SwiftUI

struct TimerView: View {
    @Bindable var vm: FocusViewModel
    @State private var showingPresets = false
    @State private var showingCustomDuration = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Progress Circle
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                    .frame(width: 280, height: 280)
                
                if vm.targetDuration != nil {
                    Circle()
                        .trim(from: 0, to: vm.progress)
                        .stroke(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .frame(width: 280, height: 280)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear, value: vm.progress)
                }
                
                VStack(spacing: 8) {
                    Text(vm.formattedCurrentTime)
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    if let target = vm.targetDuration {
                        Text("of \(vm.formatTime(target))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.top, 20)
            
            // Category Selector
            if !vm.isRunning {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(SessionCategory.allCases, id: \.self) { category in
                            CategoryButton(
                                category: category,
                                isSelected: vm.selectedCategory == category
                            ) {
                                vm.selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // Session Note
            if vm.isRunning {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(vm.selectedCategory.emoji)
                        Text(vm.selectedCategory.rawValue)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    if !vm.sessionNote.isEmpty {
                        Text(vm.sessionNote)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            } else {
                TextField("Add a note (optional)", text: $vm.sessionNote)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            // Control Buttons
            VStack(spacing: 16) {
                if !vm.isRunning {
                    // Preset Buttons
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(FocusPreset.defaults) { preset in
                                PresetButton(preset: preset) {
                                    vm.selectedCategory = preset.category
                                    vm.startTimer(targetDuration: preset.duration)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Start Button
                    Button {
                        vm.startTimer()
                    } label: {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Start Focus Session")
                        }
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                } else {
                    // Pause/Resume and Stop Buttons
                    HStack(spacing: 16) {
                        Button {
                            if vm.isPaused {
                                vm.resumeTimer()
                            } else {
                                vm.pauseTimer()
                            }
                        } label: {
                            HStack {
                                Image(systemName: vm.isPaused ? "play.fill" : "pause.fill")
                                Text(vm.isPaused ? "Resume" : "Pause")
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(16)
                        }
                        
                        Button {
                            vm.stopTimer()
                        } label: {
                            HStack {
                                Image(systemName: "stop.fill")
                                Text("Finish")
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 20)
        }
        .navigationTitle("Focus")
    }
}

struct CategoryButton: View {
    let category: SessionCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(category.emoji)
                Text(category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
            .foregroundStyle(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

struct PresetButton: View {
    let preset: FocusPreset
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(preset.category.emoji)
                    .font(.title2)
                Text(preset.name)
                    .font(.caption)
                    .fontWeight(.medium)
                Text(formatDuration(preset.duration))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 90)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        if minutes >= 60 {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return remainingMinutes > 0 ? "\(hours)h \(remainingMinutes)m" : "\(hours)h"
        }
        return "\(minutes)m"
    }
}
