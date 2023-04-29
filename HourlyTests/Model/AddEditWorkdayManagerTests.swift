//
//  AddEditWorkdayManagerTests.swift
//  HourlyTests
//
//  Created by Grayson Ruffo on 2023-04-28.
//

import XCTest
@testable import Hourly

final class AddEditWorkdayManagerTests: XCTestCase {
    var manager: AddEditWorkdayManager!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        manager = AddEditWorkdayManager()
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

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
    func test_updateAmount_withOneDollar_shouldReturnFormattedString() {
        let manager = AddEditWorkdayManager()
        let result = manager.updateAmount()
        XCTAssertEqual(result, "$0.00")
    }

    func test_validateCurrencyInput_emptyString_returnFalse() {
        var manager = AddEditWorkdayManager()
        let result = manager.validateCurrencyInput(string: "")
        XCTAssertFalse(result)
    }
    
    func test_calculateEarnings_validTimesAndNilLunch_returnDouble() {
        let manager = AddEditWorkdayManager()
        let result = manager.calculateEarnings(startTime: Date(), endTime: Date().advanced(by: 3600.0), lunchMinutes: nil, payRate: 1.0)
        XCTAssertEqual(result, 1.0)
    }
    
    func test_calculateEarnings_validTimesAndLunch_returnDouble() {
        let manager = AddEditWorkdayManager()
        let result = manager.calculateEarnings(startTime: Date(), endTime: Date().advanced(by: 3600.0), lunchMinutes: 30, payRate: 1.0)
        XCTAssertEqual(result, 0.5)
    }
    
    func test_calculateEarnings_invalidStartTime_returnZero() {
        let manager = AddEditWorkdayManager()
        let result = manager.calculateEarnings(startTime: nil, endTime: Date().advanced(by: 3600.0), lunchMinutes: 30, payRate: 1.0)
        XCTAssertEqual(result, 0.0)
    }
    
    func test_setStartTimeDate_nilStartTime_returnNil() {
        let result = manager.setStartTimeDate(startTime: nil, date: Date())
        XCTAssertNil(result)
    }
    
    func test_setEndTimeDate_nilStartTime_returnNil() {
        let result = manager.setEndTimeDate(startTime: nil, endTime: Date(), date: Date())
        XCTAssertNil(result)
    }
    
    func test_calculateTimeWorkedInMinutes_validInputs_returnMinutesWorked() {
        let result = manager.calculateTimeWorkedInMinutes(startTime: Date(), endTime: Date().advanced(by: 3600), lunchMinutes: 30)
        XCTAssertEqual(result, 30)
    }
    
    func test_calculateTimeWorkedInMinutes_invalidInputs_returnZero() {
        let result = manager.calculateTimeWorkedInMinutes(startTime: nil, endTime: Date().advanced(by: 3600), lunchMinutes: 30)
        XCTAssertEqual(result, 0)
    }
}
