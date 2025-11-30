//
//  FocusViewModel.swift
//  FocusFlow
//
//  Created by Matthew Barghout on 11/10/25.
//

import Foundation

struct FocusPreset: Identifiable {
    let id = UUID()
    let name: String
    let duration: TimeInterval
    let category: SessionCategory
    
    static let defaults = [
        FocusPreset(name: "Quick Focus", duration: 15 * 60, category: .work),
        FocusPreset(name: "Pomodoro", duration: 25 * 60, category: .study),
        FocusPreset(name: "Deep Work", duration: 90 * 60, category: .coding),
        FocusPreset(name: "Reading", duration: 30 * 60, category: .reading),
        FocusPreset(name: "Meditation", duration: 10 * 60, category: .meditation)
    ]
}

@Observable
class FocusViewModel {
    var currentSession: TimeInterval = 0
    var targetDuration: TimeInterval?
    var isRunning = false
    var isPaused = false
    var sessions: [FocusSession] = []
    var selectedCategory: SessionCategory = .work
    var sessionNote: String = ""
    
    private var timer: Timer?
    private var startTime: Date?
    
    init() {
        loadSessions()
    }
    
    // MARK: - Timer Control
    
    func startTimer(targetDuration: TimeInterval? = nil) {
        isRunning = true
        isPaused = false
        self.targetDuration = targetDuration
        startTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.currentSession += 1
            
            if let target = self.targetDuration, self.currentSession >= target {
                self.completeTimer()
            }
        }
    }
    
    func pauseTimer() {
        isPaused = true
        timer?.invalidate()
        timer = nil
    }
    
    func resumeTimer() {
        isPaused = false
        startTimer(targetDuration: targetDuration)
    }
    
    func stopTimer() {
        isRunning = false
        isPaused = false
        timer?.invalidate()
        timer = nil
        
        if currentSession > 0 {
            saveCurrentSession()
        }
        
        resetSession()
    }
    
    private func completeTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isPaused = false
        
        if currentSession > 0 {
            saveCurrentSession()
        }
        
        resetSession()
    }
    
    private func saveCurrentSession() {
        let session = FocusSession(
            duration: currentSession,
            category: selectedCategory,
            note: sessionNote.isEmpty ? nil : sessionNote
        )
        sessions.insert(session, at: 0)
        saveSessions()
    }
    
    private func resetSession() {
        currentSession = 0
        targetDuration = nil
        sessionNote = ""
        startTime = nil
    }
    
    // MARK: - Persistence
    
    func saveSessions() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: "focusSessions")
        }
    }
    
    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: "focusSessions"),
           let decoded = try? JSONDecoder().decode([FocusSession].self, from: data) {
            sessions = decoded
        }
    }
    
    func deleteSession(_ session: FocusSession) {
        sessions.removeAll { $0.id == session.id }
        saveSessions()
    }
    
    // MARK: - Formatting
    
    var formattedCurrentTime: String {
        formatTime(currentSession)
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    var progress: Double {
        guard let target = targetDuration, target > 0 else { return 0 }
        return min(currentSession / target, 1.0)
    }
    
    // MARK: - Statistics
    
    var totalFocusTime: TimeInterval {
        sessions.reduce(0) { $0 + $1.duration }
    }
    
    var todayFocusTime: TimeInterval {
        let calendar = Calendar.current
        return sessions.filter { calendar.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.duration }
    }
    
    var weekFocusTime: TimeInterval {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        return sessions.filter { $0.date >= weekAgo }
            .reduce(0) { $0 + $1.duration }
    }
    
    var averageSessionDuration: TimeInterval {
        guard !sessions.isEmpty else { return 0 }
        return totalFocusTime / Double(sessions.count)
    }
    
    func sessionsToday() -> [FocusSession] {
        let calendar = Calendar.current
        return sessions.filter { calendar.isDateInToday($0.date) }
    }
    
    func sessionsByCategory() -> [(SessionCategory, TimeInterval)] {
        var categoryTimes: [SessionCategory: TimeInterval] = [:]
        
        for session in sessions {
            categoryTimes[session.category, default: 0] += session.duration
        }
        
        return categoryTimes.sorted { $0.value > $1.value }
    }
    
    func sessionsByDay() -> [(Date, TimeInterval)] {
        let calendar = Calendar.current
        var dailyTimes: [Date: TimeInterval] = [:]
        
        for session in sessions {
            let day = calendar.startOfDay(for: session.date)
            dailyTimes[day, default: 0] += session.duration
        }
        
        return dailyTimes.sorted { $0.key > $1.key }
    }
}
