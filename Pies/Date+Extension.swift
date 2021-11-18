//
//  Date+Extension.swift
//  Pies
//
//  Created by Robert Harrison on 11/18/21.
//

import Foundation

extension Date {
    
    func getStartOfDay() -> Int {
        let calendar = Calendar(identifier: .iso8601)
        var components = calendar.dateComponents(in: TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())!, from: self)
        components.hour = 0
        components.minute = 0
        components.second = 0
        let startOfDay = Int(calendar.date(from: components)!.timeIntervalSince1970)
        return startOfDay
    }
    
    // Start of Week is Monday
    func getStartOfWeek() -> Int {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())!
        let components =  calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        let monday = calendar.date(from: components)!
        let startOfWeek = Int(monday.timeIntervalSince1970)
        return startOfWeek
    }
    
    func getStartOfMonth() -> Int {
        let calendar = Calendar(identifier: .iso8601)
        var components = calendar.dateComponents(in: TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())!, from: self)
        components.day = 1
        components.hour = 0
        components.minute = 0
        components.second = 0
        let startOfMonth = Int(calendar.date(from: components)!.timeIntervalSince1970)
        return startOfMonth
    }
    
}
