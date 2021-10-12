//
//  PiesLogger.swift
//  Pies
//
//  Created by Robert Harrison on 10/12/21.
//

import Foundation

final class PiesLogger {
    static let shared = PiesLogger()
    
    var level: PiesLogLevel = .info
    
    private lazy var dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withFullDate,
            .withTime,
            .withDashSeparatorInDate,
            .withColonSeparatorInTime,
            .withSpaceBetweenDateAndTime,
            .withFractionalSeconds
        ]
        return formatter
    }()
    
    func logInfo(message: String) {
        guard level == .info || level == .error || level == .debug else { return }
        print("\(dateFormatter.string(from: Date())) Pies [Info] \(message)")
    }
    
    func logError(message: String) {
        guard level == .error || level == .debug else { return }
        print("\(dateFormatter.string(from: Date())) Pies [Error] \(message)")
    }
    
    func logDebug(message: String) {
        guard level == .debug else { return }
        print("\(dateFormatter.string(from: Date())) Pies [Debug] \(message)")
    }
    
}
