//
//  CalendarManagerTests.swift
//  HourlyTests
//
//  Created by Grayson Ruffo on 2023-04-29.
//

import XCTest
@testable import Hourly

final class CalendarManagerTests: XCTestCase {
    var manager: CalendarManager!
    var date: Date!
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        manager = CalendarManager()
        date = Date()
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


    
    func test_plusMonth_fromTodaysMonth_returnNextMonth() {
        let result = manager.plusMonth(date: Date())
        XCTAssertEqual(result.startOfDay, Calendar.current.date(byAdding: .month, value: 1, to: date.startOfDay))
    }
    
    func test_minusMonth_fromTodaysMonth_returnPreviousMonth() {
        let result = manager.minusMonth(date: Date())
        XCTAssertEqual(result.startOfDay, Calendar.current.date(byAdding: .month, value: -1, to: date.startOfDay))
    }
    
    func test_monthString_fromTodaysMonth_returnMonthString() {
        let result = manager.monthString(date: Date())
        XCTAssertEqual(result, "April")
    }
    
    func test_yearString_fromTodaysMonth_returnYearString() {
        let result = manager.yearString(date: Date())
        XCTAssertEqual(result, "2023")
    }
    
    func test_daysInMonth_fromTodaysMonth_returnDaysCount() {
        let result = manager.daysInMonth(date: Date())
        XCTAssertEqual(result, 30)
    }
    
    func test_dayOfMonth_fromTodaysDate_returnTodaysDate() {
        let result = manager.dayOfMonth(date: Date())
        XCTAssertEqual(result, 29)
    }
    
    func test_firstOfMonth_fromTodaysDate_returnFirstOfMonth() {
        let result = manager.firstOfMonth(date: Date())
        let stringDate = "2023-04-01"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let expectedDate = dateFormatter.date(from: stringDate)
        XCTAssertEqual(result, expectedDate)
    }
    
    func test_lastOfMonth_fromTodaysDate_returnLastOfMonth() {
        let result = manager.lastOfMonth(date: Date())
        let stringDate = "2023-04-30"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let expectedDate = dateFormatter.date(from: stringDate)
        XCTAssertEqual(result, expectedDate)
    }
    
    func test_weekday_fromTodaysDate_returnDayOfWeek() {
        let result = manager.weekDay(date: Date())
        XCTAssertEqual(result, 6)
    }
}
