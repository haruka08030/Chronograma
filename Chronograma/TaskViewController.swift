//
//  TaskViewController.swift
//  Chronograma
//
//  Created by Haruka Sugiyama on 2025/4/2.
//

import SwiftUI

// MARK: - Main View

struct TaskView: View {
    @StateObject private var viewModel = TodoListViewModel()
    @State private var showingAddTodoView = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Todo List
                List {
                    ForEach(viewModel.todos) { todo in
                        TodoItemRow(todo: todo) {
                            viewModel.toggleCompletion(todo: todo)
                        }
                    }
                    .onDelete(perform: viewModel.removeTodo)
                }
                .listStyle(PlainListStyle())
                
                // Custom Tab Bar
                CustomTabBar(selectedTab: $selectedTab)
            }
            .navigationTitle("To Do")
            .navigationBarItems(trailing: Button(action: {
                showingAddTodoView = true
            }) {
                Image(systemName: "plus")
                    .font(.title2)
                    .padding(8)
                    .background(Circle().stroke(Color.gray, lineWidth: 1))
            })
            .sheet(isPresented: $showingAddTodoView) {
                AddTodoView { title, priority, dueDate in
                    viewModel.addTodo(title: title, priority: priority, dueDate: dueDate)
                    showingAddTodoView = false
                }
            }
        }
    }
}

// MARK: - Todo Item Row View

struct TodoItemRow: View {
    let todo: TodoItem
    let toggleAction: () -> Void
    
    private var formattedDueDate: String? {
        guard let dueDate = todo.dueDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: dueDate)
    }
    
    var body: some View {
        HStack {
            // Checkbox
            Button(action: toggleAction) {
                ZStack {
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color.black, lineWidth: 1)
                        .frame(width: 22, height: 22)
                    
                    if todo.isCompleted {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 22, height: 22)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Todo content
            VStack(alignment: .leading) {
                Text(todo.title)
                    .strikethrough(todo.isCompleted)
                    .foregroundColor(todo.isCompleted ? .gray : .primary)
                
                if let dateString = formattedDueDate {
                    Text("Due: \(dateString)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Priority indicator
            Circle()
                .fill(todo.priority.color)
                .frame(width: 12, height: 12)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Add Todo View

struct AddTodoView: View {
    @State private var title = ""
    @State private var priority: TodoItem.Priority = .medium
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    @Environment(\.presentationMode) var presentationMode
    
    let onSave: (String, TodoItem.Priority, Date?) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Title", text: $title)
                    
                    Picker("Priority", selection: $priority) {
                        ForEach(TodoItem.Priority.allCases, id: \.self) { priority in
                            HStack {
                                Circle()
                                    .fill(priority.color)
                                    .frame(width: 12, height: 12)
                                Text(priority.title)
                            }
                        }
                    }
                }
                
                Section(header: Text("Due Date")) {
                    Toggle("Set Due Date", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker("Date", selection: $dueDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("New Task")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    if !title.isEmpty {
                        onSave(title, priority, hasDueDate ? dueDate : nil)
                    }
                }
                .disabled(title.isEmpty)
            )
        }
    }
}

// MARK: - Custom Tab Bar Views

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(title: "今日", iconName: "calendar.day.timeline.left", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            
            TabBarButton(title: "カレンダー", iconName: "calendar", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
            
            TabBarButton(title: "ToDo", iconName: "checklist", isSelected: selectedTab == 2) {
                selectedTab = 2
            }
            
            TabBarButton(title: "Habit", iconName: "chart.bar", isSelected: selectedTab == 3) {
                selectedTab = 3
            }
            
            TabBarButton(title: "設定", iconName: "gear", isSelected: selectedTab == 4) {
                selectedTab = 4
            }
        }
        .background(Color(UIColor.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.3)),
            alignment: .top
        )
    }
}

struct TabBarButton: View {
    let title: String
    let iconName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: iconName)
                    .font(.system(size: 22))
                Text(title)
                    .font(.system(size: 10))
            }
            .foregroundColor(isSelected ? .red : .gray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview Provider

struct TaskView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
