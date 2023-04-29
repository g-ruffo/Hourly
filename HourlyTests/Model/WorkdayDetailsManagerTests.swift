//
//  WorkdayDetailsManagerTests.swift
//  HourlyTests
//
//  Created by Grayson Ruffo on 2023-04-29.
//

import XCTest
@testable import Hourly

final class WorkdayDetailsManagerTests: XCTestCase {
    var manager: WorkdayDetailsManager!
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        manager = WorkdayDetailsManager()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
    
    func test_timeToDisplayString_fromProvidedDate_returnTimeString() {
        var date = DateComponents()
        date.year = 2023
        date.month = 05
        date.day = 29
        date.hour = 12
        date.minute = 35
        date.second = 30
        let dateAndTime = Calendar.current.date(from: date)
        let result = manager.timeToDisplayString(dateAndTime)
        XCTAssertEqual(result, "12:35 PM")
    }
}


