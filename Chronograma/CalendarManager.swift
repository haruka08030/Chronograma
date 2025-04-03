//  CalendarManager.swift
//  Chronograma
//
//  Created by Haruka.S on 2025/03/15.
//

import EventKit
import SwiftUI

class CalendarManager: ObservableObject {
    private let eventStore = EKEventStore()
    @Published var events: [EKEvent] = []
    @Published var hasAccess: Bool = false
    
    init() {
        requestAccess()
    }
    
    func requestAccess() {
        eventStore.requestAccess(to: .event) { [weak self] (granted, error) in
            DispatchQueue.main.async {
                self?.hasAccess = granted
                if granted {
                    self?.fetchEvents()
                }
            }
        }
    }
    
    func fetchEvents(for date: Date = Date()) {
        guard hasAccess else { return }
        
        // Create date range for today
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date)
        var components = DateComponents()
        components.day = 1
        components.second = -1
        let endDate = calendar.date(byAdding: components, to: startDate)!
        
        // Create predicate for events within the date range
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        
        // Fetch events
        let events = eventStore.events(matching: predicate)
        DispatchQueue.main.async {
            self.events = events
        }
    }
    
    func createEvent(title: String, startDate: Date, endDate: Date, notes: String? = nil) -> Bool {
        guard hasAccess else { return false }
        
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.notes = notes
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            try eventStore.save(event, span: .thisEvent)
            fetchEvents()
            return true
        } catch {
            print("Error saving event: \(error)")
            return false
        }
    }
    
    func deleteEvent(_ event: EKEvent) -> Bool {
        guard hasAccess else { return false }
        
        do {
            try eventStore.remove(event, span: .thisEvent)
            fetchEvents()
            return true
        } catch {
            print("Error deleting event: \(error)")
            return false
        }
    }
}
