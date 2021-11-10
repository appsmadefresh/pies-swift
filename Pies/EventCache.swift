//
//  EventCache.swift
//  Pies
//
//  Created by Robert Harrison on 11/10/21.
//

import Foundation

final class EventCache {
       
    private static let eventsKey = "events"
    
    static func pushEvent(_ event: [String: Any]) {
        var events = UserDefaults.pies.array(forKey: EventCache.eventsKey) ?? [[String: Any]]()
        events.append(event)
        UserDefaults.pies.set(events, forKey: EventCache.eventsKey)
    }
    
    static func popEvent() -> [String: Any]? {
        var events = UserDefaults.pies.array(forKey: EventCache.eventsKey) ?? [[String: Any]]()
        var event: [String: Any]?
        if events.count > 0 {
            event = events.removeFirst() as? [String: Any]
            UserDefaults.pies.set(events, forKey: EventCache.eventsKey)
        }
        return event
    }
    
    static func putBackEvent(_ event: [String: Any]) {
        var events = UserDefaults.pies.array(forKey: EventCache.eventsKey) ?? [[String: Any]]()
        events.insert(event, at: 0)
        UserDefaults.pies.set(events, forKey: EventCache.eventsKey)
    }
    
}
