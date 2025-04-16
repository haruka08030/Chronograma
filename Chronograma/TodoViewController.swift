//
//  TodoViewController.swift
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
                    if viewModel.todos.isEmpty {
                        VStack {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                                .padding()
                            Text("No tasks yet")
                                .font(.headline)
                            Text("Add a new task using the + button")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
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
            .sheet (isPresented: $showingAddTodoView) {
                AddTodoView(onSave: { title, priority, dueDate, scheduledDate in
                    viewModel.addTodo(title: title, priority: priority, dueDate: dueDate, scheduledDate: scheduledDate)
                    showingAddTodoView = false
                })
                .presentationDetents([.fraction(0.25)])
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
    @State private var priority: TodoItem.Priority = .no
    
    @State private var dueDate = Date()
    @State private var scheduledDate = Date()
    @State private var scheduledEndDate = Date().addingTimeInterval(3600) // Default 1 hour later
    
    @State private var showingPriorityPicker = false
    @State private var showingDateSelectPicker = false
    
    @State private var hasDueDate = false
    @State private var hasScheduledDate = false
    
    @Environment(\.presentationMode) var presentationMode
    
    let onSave: (String, TodoItem.Priority, Date?, Date?) -> Void
    
    // FocusStateでキーボードを自動的に出す
    @FocusState private var titleFieldIsFocused: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // Task input field
            TextField("Add your task", text: $title)
                .font(.system(size: 18))
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .padding(.horizontal)
            // FocusState を TextField に適用
                .focused($titleFieldIsFocused)
            // onAppear で TextField にフォーカスを当てる
                .onAppear {
                    DispatchQueue.main.async {
                        titleFieldIsFocused = true
                    }
                }
            
            // Action buttons row
            HStack(spacing: 20) {
                // Priority button
                Menu {
                    Picker("Priority", selection: $priority) {
                        ForEach(TodoItem.Priority.allCases, id: \.self) { priorityOption in
                            Button(action: {
                                priority = priorityOption
                            }) {
                                HStack {
                                    Text(priorityOption.title)
                                    Image(systemName: "flag")
                                        .foregroundColor(priorityOption.color)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal)
                                .background(priority == priorityOption ? Color.gray.opacity(0.1) : Color.clear)
                                .cornerRadius(8)
                            }
                        }
                    }
                } label: {
                    Image(systemName: "flag")
                        .foregroundColor(priority.color)
                        .padding(8)
                        .background(Color(.tertiarySystemBackground))
                        .cornerRadius(8)
                }
                
                
                // DateSelect button
                Button(action: {
                    withAnimation {
                        showingDateSelectPicker.toggle()
                        showingPriorityPicker = false
                    }
                }) {
                    Image(systemName: hasDueDate ? "calendar.badge.clock" : "calendar")
                        .foregroundColor(hasDueDate ? .black : .gray)
                        .padding(8)
                        .background(Color(.tertiarySystemBackground))
                        .cornerRadius(8)
                }
                
                
                Spacer()
                
                // Save button
                Button(action: {
                    if !title.isEmpty {
                        onSave(
                            title,
                            priority,
                            hasDueDate ? dueDate : nil,
                            hasScheduledDate ? scheduledDate : nil
                        )
                        presentationMode.wrappedValue.dismiss() // Dismiss after saving
                    }
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            // Priority picker
            if showingPriorityPicker {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Priority")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(TodoItem.Priority.allCases, id: \.self) { priorityOption in
                        Button(action: {
                            priority = priorityOption
                        }) {
                            HStack {
                                Circle()
                                    .fill(priorityOption.color)
                                    .frame(width: 16, height: 16)
                                
                                Text(priorityOption.title)
                                
                                Spacer()
                                
                                if priority == priorityOption {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal)
                            .background(priority == priorityOption ? Color.gray.opacity(0.1) : Color.clear)
                            .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding(.top, 16)
        .sheet(isPresented: $showingDateSelectPicker) {
            DateSelectView(
                hasDueDate: $hasDueDate,
                hasScheduledDate: $hasScheduledDate,
                dueDate: $dueDate,
                scheduledDate: $scheduledDate,
                scheduledEndDate: $scheduledEndDate
            )
        }
    }
}

// MARK: - Date Select View

struct DateSelectView: View {
    @Binding var hasDueDate: Bool
    @Binding var hasScheduledDate: Bool
    @Binding var dueDate: Date
    @Binding var scheduledDate: Date
    @Binding var scheduledEndDate: Date
    @State private var selectedDate = Date()
    @State private var selectedTab = 0 // 0 for Due Date, 1 for Scheduled Date
    @State private var showingInlineTimePicker = false
    
    @Environment(\.presentationMode) var presentationMode
    
    private var formattedDueTime: String {
        if hasDueDate {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: dueDate)
        } else {
            return "None"
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.blue)
                
                Spacer()
                
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.blue)
            }
            .padding()
            
            Picker("Select Date Type", selection: $selectedTab) {
                Text("Due Date").tag(0)
                Text("Scheduled Date").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            if selectedTab == 0 {
                // Due Date Tab
                VStack {
                    DatePicker(
                        "Due date",
                        selection: $dueDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .padding()
                    
                    Divider()
                    
                    // Time option
                    HStack {
                        Image(systemName: "clock")
                        Text("Time")
                        Spacer()
                        Text(formattedDueTime)
                        if hasDueDate {
                            Button(action: {
                                withAnimation {
                                    showingInlineTimePicker = false
                                    hasDueDate = false // Due Date自体をクリア
                                }
                            }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(.gray)
                            }
                        } else {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
        
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .padding(.horizontal)
                .onTapGesture {
                                withAnimation {
                            showingInlineTimePicker.toggle()
                        }
                        print("Time tapped")
                    }
                    
                    // インライン時間ピッカー
                    if showingInlineTimePicker {
                        DatePicker(
                            "Due Time",
                            selection: $dueDate,
                            displayedComponents: [.hourAndMinute]
                        )
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .padding(.horizontal)
                        .onChange(of: dueDate) {
                            hasDueDate = true
                        }
                    }
                    
                    // Reminder option
                    HStack {
                        Image(systemName: "bell")
                        Text("Reminder")
                        Spacer()
                        Text("None")
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .onTapGesture {
                        print("Reminder tapped")
                    }
                    Spacer()
                }
            } else {
                // Scheduled Date Tab
                VStack {
                    DatePicker(
                        "Start Time",
                        selection: $scheduledDate,
                        displayedComponents: [.hourAndMinute]
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding()
                    
                    DatePicker(
                        "End Time",
                        selection: $scheduledEndDate,
                        displayedComponents: [.hourAndMinute]
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding()
                    Spacer()
                }
                .padding(.horizontal)
            }
            Spacer()
        }
    }
}

// MARK: - Preview Provider

struct TaskView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
