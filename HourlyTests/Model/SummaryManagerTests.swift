//
//  SummaryManagerTests.swift
//  HourlyTests
//
//  Created by Grayson Ruffo on 2023-04-29.
//

import XCTest
@testable import Hourly
final class SummaryManagerTests: XCTestCase {
    var manager: SummaryManager!
    var testDate: Date!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        manager = SummaryManager()
        let stringDate = "2023-04-26"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        testDate = dateFormatter.date(from: stringDate)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_firstOfWeek_fromProvidedDate_returnFirstOfWeek() {
        let result = manager.firstOfWeek(date: testDate)
        let stringExpectedDate = "2023-04-23"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let expectedDate = dateFormatter.date(from: stringExpectedDate)
        XCTAssertEqual(result, expectedDate)
    }
    
    func test_lastOfWeek_fromProvidedDate_returnLastOfWeek() {
        let result = manager.lastOfWeek(date: testDate)
        let stringExpectedDate = "2023-04-29"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let expectedDate = dateFormatter.date(from: stringExpectedDate)
        XCTAssertEqual(result, expectedDate)
    }
    
    func test_firstOfMonth_fromProvidedDate_returnFirstOfMonth() {
        let result = manager.firstOfMonth(date: testDate)
        let stringExpectedDate = "2023-04-01"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let expectedDate = dateFormatter.date(from: stringExpectedDate)
        XCTAssertEqual(result, expectedDate)
    }
    
    func test_lastOfMonth_fromProvidedDate_returnLastOfMonth() {
        let result = manager.lastOfMonth(date: testDate)
        let stringExpectedDate = "2023-04-30"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let expectedDate = dateFormatter.date(from: stringExpectedDate)
        XCTAssertEqual(result, expectedDate)
    }
    
    func test_firstOfYear_fromProvidedDate_returnFirstOfYear() {
        let result = manager.firstOfYear(date: testDate)
        let stringExpectedDate = "2023-01-01"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let expectedDate = dateFormatter.date(from: stringExpectedDate)
        XCTAssertEqual(result, expectedDate)
    }
    
    func test_lastOfYear_fromProvidedDate_returnLastOfYear() {
        let result = manager.lastOfYear(date: testDate)
        let stringExpectedDate = "2023-12-31"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let expectedDate = dateFormatter.date(from: stringExpectedDate)
        XCTAssertEqual(result, expectedDate)
    }
    
    func test_minutesToHours_givenHalfHour_returnsString() {
        let result = manager.minutesToHours(minutes: 30)
        XCTAssertEqual(result, "0.50 Hours")
    }
}
