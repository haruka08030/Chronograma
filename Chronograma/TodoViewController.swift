//
//  TaskViewController.swift
//  Chronograma
//
//  Created by Haruka Sugiyama on 2025/4/2.
//

import SwiftUI

// MARK: - ToDo View

struct TodoView: View {
    @StateObject private var viewModel = TodoListViewModel()
    @State private var showingAddTodoView = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
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
                }
                .navigationTitle("ToDo")
                
                // Floating Add Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingAddTodoView = true
                        }) {
                            Image(systemName: "plus")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                                .background(Circle().fill(Color.blue))
                                .shadow(radius: 4)
                        }
                        .padding()
                    }
                }
            }
            .sheet(isPresented: $showingAddTodoView) {
                AddTodoView { title, priority, dueDate, scheduledDate in
                    viewModel.addTodo(title: title, priority: priority, dueDate: dueDate, scheduledDate: scheduledDate)
                    showingAddTodoView = false
                }
                .presentationDetents([.medium]) // 画面の半分
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
    @State private var hasScheduledDate = false
    @State private var scheduledDate = Date()
    @Environment(\.presentationMode) var presentationMode
    
    let onSave: (String, TodoItem.Priority, Date?, Date?) -> Void
    
    var body: some View {
        VStack {
            // タスク名入力欄
            TextField("Add your task", text: $title)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .padding(.horizontal)
            
            // 記号による情報表示
            HStack {
                // Priority
                HStack {
                    Circle()
                        .fill(priority.color)
                        .frame(width: 12, height: 12)
                    Text(priority.title)
                        .font(.caption)
                }
                .padding(.horizontal)
                
                // Due Date
                if hasDueDate {
                    HStack {
                        Image(systemName: "calendar")
                        Text(dueDate, style: .date)
                            .font(.caption)
                    }
                    .padding(.horizontal)
                }
                
                // Scheduled Date
                if hasScheduledDate {
                    HStack {
                        Image(systemName: "clock")
                        Text(scheduledDate, style: .date)
                            .font(.caption)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.top, 8)
            
            // Due Date と Scheduled Date の設定
            HStack {
                Toggle("期日", isOn: $hasDueDate)
                Spacer()
                if hasDueDate {
                    DatePicker("期日", selection: $dueDate, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                }
            }
            .padding(.horizontal)
            
            HStack {
                Toggle("予定実行日", isOn: $hasScheduledDate)
                Spacer()
                if hasScheduledDate {
                    DatePicker("予定実行日", selection: $scheduledDate, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // 保存ボタン
            Button(action: {
                if !title.isEmpty {
                    onSave(title, priority, hasDueDate ? dueDate : nil, hasScheduledDate ? scheduledDate : nil)
                }
            }) {
                Text("保存")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .padding(.vertical)
    }
}



// MARK: - Preview Provider

struct TaskView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
