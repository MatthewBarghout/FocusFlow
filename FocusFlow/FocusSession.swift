//
//  FocusSession.swift
//  FocusFlow
//
//  Created by Matthew Barghout on 11/10/25.
//

import Foundation

enum SessionCategory: String, Codable, CaseIterable {
    case work = "Work"
    case study = "Study"
    case reading = "Reading"
    case coding = "Coding"
    case exercise = "Exercise"
    case meditation = "Meditation"
    case other = "Other"
    
    var emoji: String {
        switch self {
        case .work: return "💼"
        case .study: return "📚"
        case .reading: return "📖"
        case .coding: return "💻"
        case .exercise: return "🏃"
        case .meditation: return "🧘"
        case .other: return "✨"
        }
    }
}

struct FocusSession: Identifiable, Codable {
    let id: UUID
    let duration: TimeInterval
    let date: Date
    var category: SessionCategory
    var note: String?
    
    init(duration: TimeInterval, category: SessionCategory = .other, note: String? = nil) {
        self.id = UUID()
        self.duration = duration
        self.date = Date()
        self.category = category
        self.note = note
    }
    
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    var shortFormattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
