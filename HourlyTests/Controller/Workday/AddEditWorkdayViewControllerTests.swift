//
//  AddEditWorkdayViewControllerTests.swift
//  HourlyTests
//
//  Created by Grayson Ruffo on 2023-05-03.
//

import XCTest
@testable import Hourly
final class AddEditWorkdayViewControllerTests: XCTestCase {
    var systemUnderTest: AddEditWorkdayViewController!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        systemUnderTest = storyboard.instantiateViewController(withIdentifier: "AddEditWorkdayViewController") as? AddEditWorkdayViewController
        
        _ = systemUnderTest.view
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

    
    func test_dateEndTimePickerStartingValues_EqualsToday() {
        let date = systemUnderTest.datePicker.date
        
        XCTAssertEqual(date, date)
    }

}
