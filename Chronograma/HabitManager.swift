//
//  HabitManager.swift
//  Chronograma
//
//  Created by Haruka.S on 2025/03/15.
//
// 習慣管理クラス

import SwiftUI
import Foundation

// MARK: - Data Model

struct Habit: Identifiable, Codable {
    var id = UUID()
    var title: String
    var days: [Bool] = [false, false, false, false, false, false, false] // 月火水木金土日
    var startTime: Date
    var endTime: Date
    var color: String = "red" // For UI representation
    
    var formattedTimeRange: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }
    
    func colorValue() -> Color {
        switch color {
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "purple": return .purple
        case "orange": return .orange
        default: return .gray
        }
    }
}

// MARK: - View Model

class HabitViewModel: ObservableObject {
    @Published var habits: [Habit] = [] {
        didSet {
            saveHabits()
        }
    }
    
    private let habitsKey = "savedHabits"
    
    init() {
        loadHabits()
        
        // Add default habits if none exist
        if habits.isEmpty {
            let calendar = Calendar.current
            let morning = calendar.date(bySettingHour: 7, minute: 0, second: 0, of: Date())!
            let evening = calendar.date(bySettingHour: 22, minute: 0, second: 0, of: Date())!
            let workStart = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
            let workEnd = calendar.date(bySettingHour: 17, minute: 0, second: 0, of: Date())!
            
            // 起床習慣 (Wake up habit)
            let wakeUpHabit = Habit(
                title: "起床",
                days: [true, true, true, true, true, false, false], // 平日のみ
                startTime: morning,
                endTime: morning,
                color: "orange"
            )
            
            // 仕事習慣 (Work habit)
            let workHabit = Habit(
                title: "仕事",
                days: [true, true, true, true, true, false, false], // 平日のみ
                startTime: workStart,
                endTime: workEnd,
                color: "blue"
            )
            
            // 就寝習慣 (Sleep habit)
            let sleepHabit = Habit(
                title: "就寝",
                days: [true, true, true, true, true, true, true], // 毎日
                startTime: evening,
                endTime: evening,
                color: "purple"
            )
            
            habits = [wakeUpHabit, workHabit, sleepHabit]
        }
    }
    
    func addHabit(title: String, days: [Bool], startTime: Date, endTime: Date, color: String) {
        let newHabit = Habit(title: title, days: days, startTime: startTime, endTime: endTime, color: color)
        habits.append(newHabit)
    }
    
    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
        }
    }
    
    func deleteHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
    }
    
    func getHabitsForDay(_ dayIndex: Int) -> [Habit] {
        return habits.filter { $0.days[dayIndex] }
    }
    
    // Persistence
    private func saveHabits() {
        if let encodedData = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encodedData, forKey: habitsKey)
        }
    }
    
    private func loadHabits() {
        if let data = UserDefaults.standard.data(forKey: habitsKey),
           let decodedHabits = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = decodedHabits
        }
    }
}
