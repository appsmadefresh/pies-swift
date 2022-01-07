//
//  TimeInterval+Extension.swift
//  Pies
//
//  Created by Robert Harrison on 1/6/22.
//

import Foundation

extension DateFormatter {
    static func formattedString(using timeInterval: TimeInterval) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter.string(from: Date(timeIntervalSince1970: timeInterval))
    }
}
