//
//  CalendarViewControllerTests.swift
//  HourlyTests
//
//  Created by Grayson Ruffo on 2023-04-29.
//

import XCTest
@testable import Hourly
final class CalendarViewControllerTests: XCTestCase {
    var systemUnderTest: CalendarViewController!
    
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        systemUnderTest = storyboard.instantiateViewController(withIdentifier: "CalendarViewController") as? CalendarViewController
        _ = systemUnderTest.view
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        systemUnderTest = nil
    }

    
    func testCurrentSelectedMonthIsEqualToApril() {
        let monthLabel = systemUnderTest.monthLabel
        XCTAssertEqual(monthLabel?.text, "April 2023")
    }
}
