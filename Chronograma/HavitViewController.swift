//
//  HavitViewController.swift
//  Chronograma
//
//  Created by Haruka Sugiyama on 2025/4/6.
//


import SwiftUI

//MARK: -Habit View
struct HabitView: View {
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
                    
                    .navigationTitle("Habit")
                    
                    List {
                        Text("習慣項目がここに表示されます")
                            .foregroundColor(.gray)
                    }
                }
                
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
        }
    }
}

// MARK: - Preview Provider
struct HabitView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
