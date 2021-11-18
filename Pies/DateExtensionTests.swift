//
//  DateExtensionTests.swift
//  PiesTests
//
//  Created by Robert Harrison on 11/18/21.
//

import XCTest
@testable import Pies

final class DateExtensionTests: XCTestCase {

    func testStartOfDay() throws {
        let morning = Date(timeIntervalSince1970: 1636478589)
        XCTAssertEqual(morning.getStartOfDay(), 1636444800)
        
        let afternoon = Date(timeIntervalSince1970: 1636495200)
        XCTAssertEqual(afternoon.getStartOfDay(), 1636444800)
        
        let evening = Date(timeIntervalSince1970: 1636484400)
        XCTAssertEqual(evening.getStartOfDay(), 1636444800)
    }
    
    func testStartOfWeek() throws {
        
        let jan1 = Date(timeIntervalSince1970: 1609531560) // Friday, Jan 1, 2021
        XCTAssertEqual(jan1.getStartOfWeek(), 1609142400) // start of week is Monday, Dec 28, 2020
        
        let oct3 = Date(timeIntervalSince1970: 1633287960) // Sunday, Oct 3, 2021
        XCTAssertEqual(oct3.getStartOfWeek(), 1632729600) // start of week is Monday, Sep 27, 2021
        
        let nov1 = Date(timeIntervalSince1970: 1635793560) // Monday, Nov 1, 2021
        XCTAssertEqual(nov1.getStartOfWeek(), 1635753600) // start of week is Monday, Nov 1, 2021
        
        let nov3 = Date(timeIntervalSince1970: 1635966360) // Wednesday, Nov 3, 2021
        XCTAssertEqual(nov3.getStartOfWeek(), 1635753600) // start of week is Monday, Nov 1, 2021
        
        let nov17 = Date(timeIntervalSince1970: 1637216642) // Wednesday, Nov 17, 2021
        XCTAssertEqual(nov17.getStartOfWeek(), 1636963200) // start of week is Monday, Nov 15, 2021
        
        let nov18 = Date(timeIntervalSince1970: 1637256685) // Thursday, Nov 18, 2021
        XCTAssertEqual(nov18.getStartOfWeek(), 1636963200) // start of week is Monday, Nov 15, 2021
    }
    
    func testStartOfMonth() throws {
        let nov17 = Date(timeIntervalSince1970: 1637216642) // Wednesday, Nov 17, 2021
        XCTAssertEqual(nov17.getStartOfMonth(), 1635753600) // start of month is Monday, Nov 1, 2021
    }
}
