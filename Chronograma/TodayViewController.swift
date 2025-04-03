//
//  TodayViewController.swift
//  Chronograma
//
//  Created by Haruka.S on 2025/04/03.
//

import SwiftUI
import EventKit

struct ScheduleItem: Identifiable {
    let id = UUID()
    let title: String
    let startTime: Date
    let endTime: Date
    let color: Color
    let isCompleted: Bool
    let type: ItemType
    
    enum ItemType {
        case event
        case task
        case habit
    }
}

struct TodayView: View {
    @StateObject private var calendarManager = CalendarManager()
    @StateObject private var todoViewModel = TodoListViewModel()
    @StateObject private var habitViewModel = HabitViewModel()
    
    @State private var scheduleItems: [ScheduleItem] = []
    @State private var currentDate = Date()
    
    var body: some View {
        NavigationView {
            List {
                // Date header
                VStack(alignment: .leading) {
                    Text(dateString)
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(dayString)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .listRowInsets(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
                .background(Color(UIColor.systemBackground))
                
                if scheduleItems.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("今日の予定はありません")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .listRowInsets(EdgeInsets())
                } else {
                    // Schedule items
                    ForEach(scheduleItems) { item in
                        ScheduleItemRow(item: item)
                    }
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("今日")
            .navigationBarItems(
                trailing: Button(action: {
                    refreshData()
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            )
            .onAppear {
                refreshData()
            }
        }
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: currentDate)
    }
    
    private var dayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: currentDate)
    }
    
    private func refreshData() {
        // Reset items
        scheduleItems = []
        
        // Get the day of week index (0 = Monday, 6 = Sunday in our system)
        let calendar = Calendar(identifier: .gregorian)
        var dayOfWeekIndex = calendar.component(.weekday, from: currentDate) - 2
        if dayOfWeekIndex < 0 {
            dayOfWeekIndex = 6 // Sunday becomes index 6
        }
        
        // Add calendar events
        calendarManager.fetchEvents(for: currentDate)
        for event in calendarManager.events {
            scheduleItems.append(
                ScheduleItem(
                    title: event.title,
                    startTime: event.startDate,
                    endTime: event.endDate,
                    color: .blue,
                    isCompleted: false,
                    type: .event
                )
            )
        }
        
        // Add todos for today
        for todo in todoViewModel.todos {
            if let dueDate = todo.dueDate, calendar.isDate(dueDate, inSameDayAs: currentDate) {
                // Creating a time that's at the end of the day for display purposes
                let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: dueDate)!
                
                scheduleItems.append(
                    ScheduleItem(
                        title: todo.title,
                        startTime: dueDate,
                        endTime: endOfDay,
                        color: todo.priority.color,
                        isCompleted: todo.isCompleted,
                        type: .task
                    )
                )
            }
        }
        
        // Add habits for the current day of week
        for habit in habitViewModel.getHabitsForDay(dayOfWeekIndex) {
            scheduleItems.append(
                ScheduleItem(
                    title: habit.title,
                    startTime: habit.startTime,
                    endTime: habit.endTime,
                    color: habit.colorValue(),
                    isCompleted: false,
                    type: .habit
                )
            )
        }
        
        // Sort by start time
        scheduleItems.sort { $0.startTime < $1.startTime }
    }
}

struct ScheduleItemRow: View {
    let item: ScheduleItem
    
    var body: some View {
        HStack(spacing: 15) {
            // Time column
            VStack(alignment: .leading) {
                Text(formatTime(item.startTime))
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                if item.startTime != item.endTime {
                    Text(formatTime(item.endTime))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 60, alignment: .leading)
            
            // Color indicator
            RoundedRectangle(cornerRadius: 3)
                .fill(item.color)
                .frame(width: 4)
                .padding(.vertical, 8)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                // Title with completion status for tasks
                HStack {
                    Text(item.title)
                        .strikethrough(item.isCompleted)
                        .fontWeight(.medium)
                        .foregroundColor(item.isCompleted ? .gray : .primary)
                    
                    Spacer()
                    
                    // Icon indicating type
                    Image(systemName: typeIcon)
                        .foregroundColor(.gray)
                }
                
                // Type indicator
                Text(typeLabel)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private var typeLabel: String {
        switch item.type {
        case .event:
            return "予定"
        case .task:
            return "タスク"
        case .habit:
            return "習慣"
        }
    }
    
    private var typeIcon: String {
        switch item.type {
        case .event:
            return "calendar"
        case .task:
            return "checkmark.circle"
        case .habit:
            return "repeat"
        }
    }
}
