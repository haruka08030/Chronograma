//
//  TaskManager.swift
//  Chronograma
//
//  Created by Haruka.S on 2025/03/15.
//

import SwiftUI
import Foundation

// MARK: - Data Model

struct TodoItem: Identifiable, Codable {
    var id = UUID()
    var title: String
    var isCompleted: Bool = false
    var priority: Priority = .medium
    var dueDate: Date?
    var scheduledDate: Date?
    
    enum Priority: Int, Codable, CaseIterable {
        case high = 0
        case medium = 1
        case low = 2
        case no = 3
        
        var color: Color {
            switch self {
            case .high: return .red
            case .medium: return .orange
            case .low: return .green
            case .no: return .gray
            }
        }
        
        var title: String {
            switch self {
            case .high: return "High"
            case .medium: return "Medium"
            case .low: return "Low"
            case .no: return "No"
            }
        }
    }
}

// MARK: - View Model

class TodoListViewModel: ObservableObject {
    @Published var todos: [TodoItem] = [] {
        didSet {
            saveTodos()
        }
    }
    
    enum SortType {
        case priority
        case dueDate
        //case scheduledDate
        //case title
        //case creationDate
    }
    
    init() {
        loadTodos()
    }
    
    func addTodo(title: String, priority: TodoItem.Priority, dueDate: Date?, scheduledDate: Date?) {
        let newTodo = TodoItem(title: title, priority: priority, dueDate: dueDate, scheduledDate: scheduledDate)
        todos.append(newTodo)
    }
    
    func toggleCompletion(todo: TodoItem) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index].isCompleted.toggle()
        }
    }
    
    func removeTodo(at indexSet: IndexSet) {
        todos.remove(atOffsets: indexSet)
    }
    
    func filteredTodos(showCompleted: Bool = true, priorityFilter: TodoItem.Priority? = nil) -> [TodoItem] {
        return todos.filter { todo in
            (showCompleted || !todo.isCompleted) &&
            (priorityFilter == nil || todo.priority == priorityFilter)
        }
    }

    func sortedTodos(by sortType: SortType) -> [TodoItem] {
        switch sortType {
        case .priority:
            return todos.sorted { $0.priority.rawValue < $1.priority.rawValue }
        case .dueDate:
            return todos.sorted {
                if let date1 = $0.dueDate, let date2 = $1.dueDate {
                    return date1 < date2
                }
                return $0.dueDate != nil && $1.dueDate == nil
            }
        }
    }
    
    // Persistence
    private func saveTodos() {
        if let encodedData = try? JSONEncoder().encode(todos) {
            UserDefaults.standard.set(encodedData, forKey: "todos")
        }
    }
    
    private func loadTodos() {
        if let data = UserDefaults.standard.data(forKey: "todos"),
           let decodedTodos = try? JSONDecoder().decode([TodoItem].self, from: data) {
            todos = decodedTodos
        }
    }
    
}
