//
//  ContentView.swift
//  Chronograma
//
//  Created by Haruka.S on 2025/03/15.
//


import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView()  // This now refers to the real implementation in TodayViewController.swift
                .tag(0)
                .tabItem {
                    Image(systemName: "calendar.day.timeline.left")
                    Text("今日")
                }
            
            CalendarView()
                .tag(1)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("カレンダー")
                }
            
            TaskView()
                .tag(2)
                .tabItem {
                    Image(systemName: "checklist")
                    Text("ToDo")
                }
            
            HabitView()
                .tag(3)
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Habit")
                }
            
            SettingsView()
                .tag(4)
                .tabItem {
                    Image(systemName: "gear")
                    Text("設定")
                }
        }
        .accentColor(.red)
    }
}

// MARK: - Placeholder Views
struct TodayPlaceholderView: View {  // Renamed from TodayView
    var body: some View {
        NavigationView {
            VStack {
                Text("今日のスケジュール")
                    .font(.largeTitle)
                
                Spacer()
                
                Text("本日の予定がここに表示されます")
                    .foregroundColor(.gray)
                
                Spacer()
            }
            .navigationTitle("今日")
        }
    }
}

struct CalendarView: View {
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "日付を選択",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
                
                List {
                    Text("この日の予定がここに表示されます")
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("カレンダー")
        }
    }
}

struct HabitView: View {
    var days = ["月", "火", "水", "木", "金", "土", "日"]
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    ForEach(days, id: \.self) { day in
                        Text(day)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.1))
                    }
                }
                .padding(.horizontal)
                
                List {
                    Text("習慣項目がここに表示されます")
                        .foregroundColor(.gray)
                }
                
                Button(action: {
                    // Add new habit
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.red)
                }
                .padding()
            }
            .navigationTitle("習慣")
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("アカウント")) {
                    Text("プロフィール")
                    Text("通知設定")
                }
                
                Section(header: Text("アプリ情報")) {
                    Text("バージョン 1.0")
                    Text("プライバシーポリシー")
                }
            }
            .navigationTitle("設定")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
