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
    
    enum Priority: Int, Codable, CaseIterable {
        case low = 0
        case medium = 1
        case high = 2
        
        var color: Color {
            switch self {
            case .low: return .green
            case .medium: return .orange
            case .high: return .red
            }
        }
        
        var title: String {
            switch self {
            case .low: return "Low"
            case .medium: return "Medium"
            case .high: return "High"
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
    
    init() {
        loadTodos()
    }
    
    func addTodo(title: String, priority: TodoItem.Priority, dueDate: Date?) {
        let newTodo = TodoItem(title: title, priority: priority, dueDate: dueDate)
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
