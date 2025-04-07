//
//  HabitViewController.swift
//  Chronograma
//
//  Created by Haruka Sugiyama on 2025/4/6.
//


import SwiftUI

//MARK: -Habit View
struct HabitView: View {
    @StateObject private var habitViewModel = HabitViewModel()
    @State private var showingAddHabitView = false
    @State private var selectedTab = 0
    
    var days = ["月", "火", "水", "木", "金", "土", "日"]
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    HStack {
                        ForEach(days, id: \ .self) { day in
                            Text(day)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.1))
                        }
                    }
                    .padding(.horizontal)
                    
                    if habitViewModel.habits.isEmpty {
                        VStack {
                            Image(systemName: "chart.bar")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                                .padding()
                            Text("No habits yet")
                                .font(.headline)
                            Text("Add a new habit using the + button")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(habitViewModel.habits) { habit in
                                HabitItemRow(habit: habit)
                            }
                            .onDelete { indexSet in
                                for index in indexSet {
                                    let habit = habitViewModel.habits[index]
                                    habitViewModel.deleteHabit(habit)
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                .navigationTitle("Habit")
                
                // Floating Add Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingAddHabitView = true
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
            .sheet(isPresented: $showingAddHabitView) {
                AddHabitView { title, days, startTime, endTime, color in
                    habitViewModel.addHabit(title: title, days: days, startTime: startTime, endTime: endTime, color: color)
                }
            }
        }
    }
}

// MARK: - Habit Item Row
struct HabitItemRow: View {
    let habit: Habit
    
    var body: some View {
        HStack {
            // Color indicator
            Rectangle()
                .fill(habit.colorValue())
                .frame(width: 4)
                .padding(.vertical, 8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.title)
                    .font(.headline)
                
                Text(habit.formattedTimeRange)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                // Days of week
                HStack(spacing: 4) {
                    ForEach(0..<7) { index in
                        Text(["M", "T", "W", "T", "F", "S", "S"][index])
                            .font(.system(size: 10))
                            .frame(width: 16, height: 16)
                            .background(habit.days[index] ? habit.colorValue().opacity(0.3) : Color.clear)
                            .cornerRadius(8)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Add Habit View
struct AddHabitView: View {
    @State private var title: String = ""
    @State private var days: [Bool] = [false, false, false, false, false, false, false]
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(3600)
    @State private var selectedColor: String = "blue"
    
    @Environment(\.presentationMode) var presentationMode
    
    let colors = ["red", "blue", "green", "purple", "orange"]
    let onSave: (String, [Bool], Date, Date, String) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Habit Details")) {
                    TextField("Habit title", text: $title)
                    
                    DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                    
                    DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                }
                
                Section(header: Text("Days")) {
                    VStack(alignment: .leading) {
                        HStack {
                            ForEach(0..<7) { index in
                                Button(action: {
                                    days[index].toggle()
                                }) {
                                    Text(["月", "火", "水", "木", "金", "土", "日"][index])
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(days[index] ? Color.blue.opacity(0.3) : Color.gray.opacity(0.1))
                                        .cornerRadius(5)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                
                Section(header: Text("Color")) {
                    HStack {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(colorValue(color))
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle()
                                        .stroke(color == selectedColor ? Color.black : Color.clear, lineWidth: 2)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                                .padding(.horizontal, 5)
                        }
                    }
                }
            }
            .navigationBarTitle("New Habit", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    if !title.isEmpty {
                        onSave(title, days, startTime, endTime, selectedColor)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .disabled(title.isEmpty)
            )
        }
    }
    
    func colorValue(_ colorName: String) -> Color {
        switch colorName {
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "purple": return .purple
        case "orange": return .orange
        default: return .gray
        }
    }
}

// MARK: - Preview Provider
struct HabitView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
