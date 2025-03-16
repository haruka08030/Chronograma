//
//  Untitled.swift
//  Cronograma
//
//  Created by Haruka.S on 2025/03/11.
//

import SwiftUI
import EventKit

// メインアプリ構造体
@main
struct Chronograma: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(CalendarManager())
                .environmentObject(TaskManager())
                .environmentObject(HabitManager())
        }
    }
}

// カレンダーマネージャクラス
class CalendarManager: ObservableObject {
    private let eventStore = EKEventStore()
    @Published var events: [EKEvent] = []
    
    init() {
        requestAccess()
    }
    
    func requestAccess() {
        eventStore.requestAccess(to: .event) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    self.fetchEvents()
                }
            }
        }
    }
    
    func fetchEvents() {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = 0
        components.minute = 0
        components.second = 0
        
        guard let startDate = calendar.date(from: components) else { return }
        guard let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) else { return }
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        self.events = eventStore.events(matching: predicate)
    }
}

// タスク管理クラス
class TaskManager: ObservableObject {
    @Published var tasks: [Task] = [
        Task(title: "プロジェクト会議", priority: .high, dueTime: "10:00"),
        Task(title: "メール返信", priority: .medium, dueTime: "13:00"),
        Task(title: "レポート作成", priority: .medium, dueTime: "15:00")
    ]
    
    func addTask(task: Task) {
        tasks.append(task)
    }
    
    func toggleCompletion(for taskId: UUID) {
        if let index = tasks.firstIndex(where: { $0.id == taskId }) {
            tasks[index].isCompleted.toggle()
        }
    }
}

// 習慣管理クラス
class HabitManager: ObservableObject {
    @Published var habits: [Habit] = [
        Habit(title: "朝のストレッチ", timeOfDay: "07:00"),
        Habit(title: "水分補給", timeOfDay: "毎時"),
        Habit(title: "読書", timeOfDay: "22:00")
    ]
    
    func addHabit(habit: Habit) {
        habits.append(habit)
    }
    
    func toggleCompletion(for habitId: UUID) {
        if let index = habits.firstIndex(where: { $0.id == habitId }) {
            habits[index].isCompleted.toggle()
        }
    }
}

// タスクモデル
struct Task: Identifiable {
    var id = UUID()
    var title: String
    var priority: Priority
    var dueTime: String
    var isCompleted: Bool = false
    var notes: String = ""
    
    enum Priority: String, CaseIterable {
        case high = "高"
        case medium = "中"
        case low = "低"
        
        var color: Color {
            switch self {
            case .high: return .red
            case .medium: return .orange
            case .low: return .blue
            }
        }
    }
}

// 習慣モデル
struct Habit: Identifiable {
    var id = UUID()
    var title: String
    var timeOfDay: String
    var isCompleted: Bool = false
    var streak: Int = 0
}

// 統合されたタイムラインアイテム
struct TimelineItem: Identifiable {
    var id = UUID()
    var time: String
    var title: String
    var type: ItemType
    var isCompleted: Bool
    var originalId: UUID?
    
    enum ItemType: String {  // String型に変更
        case event = "イベント"
        case task = "タスク"
        case habit = "習慣"
        
        var color: Color {
            switch self {
            case .event: return .blue
            case .task: return .orange
            case .habit: return .green
            }
        }
        
        var icon: String {
            switch self {
            case .event: return "calendar"
            case .task: return "checkmark.square"
            case .habit: return "repeat"
            }
        }
    }
}

// メインコンテンツビュー
struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DailyScheduleView()
                .tabItem {
                    Label("スケジュール", systemImage: "calendar.day.timeline.left")
                }
                .tag(0)
            
            TasksView()
                .tabItem {
                    Label("タスク", systemImage: "checklist")
                }
                .tag(1)
            
            HabitsView()
                .tabItem {
                    Label("習慣", systemImage: "repeat")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gear")
                }
                .tag(3)
        }
    }
}

// 日々のスケジュールビュー
struct DailyScheduleView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var habitManager: HabitManager
    @State private var date = Date()
    @State private var timelineItems: [TimelineItem] = []
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("", selection: $date, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                
                List {
                    ForEach(timelineItems) { item in
                        TimelineItemRow(item: item)
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("デイリープランナー")
            .navigationBarItems(trailing: Button(action: {
                // 新規予定追加アクション
            }) {
                Image(systemName: "plus")
            })
            .onAppear {
                generateTimelineItems()
            }
        }
    }
    
    func generateTimelineItems() {
        var items: [TimelineItem] = []
        
        // カレンダーイベントの追加
        for event in calendarManager.events {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            let timeString = formatter.string(from: event.startDate)
            
            items.append(TimelineItem(
                time: timeString,
                title: event.title,
                type: .event,
                isCompleted: false
            ))
        }
        
        // タスクの追加
        for task in taskManager.tasks {
            items.append(TimelineItem(
                time: task.dueTime,
                title: task.title,
                type: .task,
                isCompleted: task.isCompleted,
                originalId: task.id
            ))
        }
        
        // 習慣の追加
        for habit in habitManager.habits {
            items.append(TimelineItem(
                time: habit.timeOfDay,
                title: habit.title,
                type: .habit,
                isCompleted: habit.isCompleted,
                originalId: habit.id
            ))
        }
        
        // 時間順にソート
        items.sort { item1, item2 in
            let time1Components = item1.time.split(separator: ":")
            let time2Components = item2.time.split(separator: ":")
            
            if time1Components.count >= 2 && time2Components.count >= 2 {
                let hour1 = Int(time1Components[0]) ?? 0
                let hour2 = Int(time2Components[0]) ?? 0
                
                if hour1 != hour2 {
                    return hour1 < hour2
                }
                
                let minute1 = Int(time1Components[1]) ?? 0
                let minute2 = Int(time2Components[1]) ?? 0
                return minute1 < minute2
            }
            
            return item1.time < item2.time
        }
        
        timelineItems = items
    }
}

// タイムラインアイテム行
struct TimelineItemRow: View {
    let item: TimelineItem
    @EnvironmentObject var taskManager: TaskManager
    @EnvironmentObject var habitManager: HabitManager
    
    var body: some View {
        HStack {
            Text(item.time)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .leading)
            
            Rectangle()
                .fill(item.type.color)
                .frame(width: 4, height: 50)
                .cornerRadius(2)
            
            VStack(alignment: .leading) {
                Text(item.title)
                    .font(.headline)
                    .strikethrough(item.isCompleted)
                
                Text(item.type.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if item.type != .event {
                Button(action: {
                    toggleCompletion()
                }) {
                    Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(item.type.color)
                }
            }
            
            Image(systemName: item.type.icon)
                .foregroundColor(item.type.color)
        }
        .padding(.vertical, 4)
    }
    
    func toggleCompletion() {
        guard let originalId = item.originalId else { return }
        
        switch item.type {
        case .task:
            taskManager.toggleCompletion(for: originalId)
        case .habit:
            habitManager.toggleCompletion(for: originalId)
        default:
            break
        }
    }
}

// タスク管理ビュー
struct TasksView: View {
    @EnvironmentObject var taskManager: TaskManager
    @State private var showingAddTask = false
    @State private var newTaskTitle = ""
    @State private var newTaskPriority = Task.Priority.medium
    @State private var newTaskDueTime = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(taskManager.tasks) { task in
                    TaskRow(task: task)
                }
                .onDelete { indexSet in
                    // タスク削除ロジック
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("タスク")
            .navigationBarItems(trailing: Button(action: {
                showingAddTask = true
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingAddTask) {
                AddTaskView(
                    isPresented: $showingAddTask,
                    title: $newTaskTitle,
                    priority: $newTaskPriority,
                    dueTime: $newTaskDueTime,
                    onSave: addTask
                )
            }
        }
    }
    
    func addTask() {
        let newTask = Task(
            title: newTaskTitle,
            priority: newTaskPriority,
            dueTime: newTaskDueTime
        )
        taskManager.addTask(task: newTask)
        newTaskTitle = ""
        newTaskDueTime = ""
    }
}

// タスク行
struct TaskRow: View {
    let task: Task
    @EnvironmentObject var taskManager: TaskManager
    
    var body: some View {
        HStack {
            Button(action: {
                taskManager.toggleCompletion(for: task.id)
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.priority.color)
            }
            
            VStack(alignment: .leading) {
                Text(task.title)
                    .font(.headline)
                    .strikethrough(task.isCompleted)
                
                HStack {
                    Text(task.dueTime)
                        .font(.caption)
                    
                    Text(task.priority.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(task.priority.color.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// 新規タスク追加ビュー
struct AddTaskView: View {
    @Binding var isPresented: Bool
    @Binding var title: String
    @Binding var priority: Task.Priority
    @Binding var dueTime: String
    var onSave: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("タスク詳細")) {
                    TextField("タイトル", text: $title)
                    
                    TextField("時間 (HH:MM)", text: $dueTime)
                        .keyboardType(.numberPad)
                    
                    Picker("優先度", selection: $priority) {
                        ForEach(Task.Priority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                }
            }
            .navigationTitle("新規タスク")
            .navigationBarItems(
                leading: Button("キャンセル") { isPresented = false },
                trailing: Button("保存") {
                    onSave()
                    isPresented = false
                }
                .disabled(title.isEmpty || dueTime.isEmpty)
            )
        }
    }
}

// 習慣管理ビュー
struct HabitsView: View {
    @EnvironmentObject var habitManager: HabitManager
    @State private var showingAddHabit = false
    @State private var newHabitTitle = ""
    @State private var newHabitTime = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(habitManager.habits) { habit in
                    HabitRow(habit: habit)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("習慣")
            .navigationBarItems(trailing: Button(action: {
                showingAddHabit = true
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView(
                    isPresented: $showingAddHabit,
                    title: $newHabitTitle,
                    timeOfDay: $newHabitTime,
                    onSave: addHabit
                )
            }
        }
    }
    
    func addHabit() {
        let newHabit = Habit(
            title: newHabitTitle,
            timeOfDay: newHabitTime
        )
        habitManager.addHabit(habit: newHabit)
        newHabitTitle = ""
        newHabitTime = ""
    }
}

// 習慣行
struct HabitRow: View {
    let habit: Habit
    @EnvironmentObject var habitManager: HabitManager
    
    var body: some View {
        HStack {
            Button(action: {
                habitManager.toggleCompletion(for: habit.id)
            }) {
                Image(systemName: habit.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(.green)
            }
            
            VStack(alignment: .leading) {
                Text(habit.title)
                    .font(.headline)
                    .strikethrough(habit.isCompleted)
                
                HStack {
                    Text(habit.timeOfDay)
                        .font(.caption)
                    
                    Text("\(habit.streak)日連続")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            
            Spacer()
            
            Image(systemName: "repeat")
                .foregroundColor(.green)
        }
        .padding(.vertical, 4)
    }
}

// 新規習慣追加ビュー
struct AddHabitView: View {
    @Binding var isPresented: Bool
    @Binding var title: String
    @Binding var timeOfDay: String
    var onSave: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("習慣詳細")) {
                    TextField("タイトル", text: $title)
                    TextField("時間 (HH:MM または 説明)", text: $timeOfDay)
                }
            }
            .navigationTitle("新規習慣")
            .navigationBarItems(
                leading: Button("キャンセル") { isPresented = false },
                trailing: Button("保存") {
                    onSave()
                    isPresented = false
                }
                .disabled(title.isEmpty || timeOfDay.isEmpty)
            )
        }
    }
}

// 設定ビュー
struct SettingsView: View {
    @AppStorage("userName") private var userName = ""
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("プロフィール")) {
                    TextField("名前", text: $userName)
                }
                
                Section(header: Text("通知")) {
                    Toggle("通知を有効にする", isOn: $notificationsEnabled)
                }
                
                Section(header: Text("表示")) {
                    Toggle("ダークモード", isOn: $darkModeEnabled)
                }
                
                Section(header: Text("カレンダー")) {
                    Button("カレンダーアクセスを管理") {
                        // カレンダー設定画面へ
                    }
                }
                
                Section(header: Text("アプリについて")) {
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("設定")
        }
    }
}
