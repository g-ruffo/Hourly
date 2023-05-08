//
//  SummaryViewControllerTests.swift
//  HourlyTests
//
//  Created by Grayson Ruffo on 2023-05-07.
//

import XCTest
@testable import Hourly
final class SummaryViewControllerTests: XCTestCase {
    private var systemUnderTest: SummaryViewController!
    private var coreDataServiceMock: CoreDataServiceMock!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        coreDataServiceMock = CoreDataServiceMock()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        systemUnderTest = storyboard.instantiateViewController(withIdentifier: "SummaryViewController") as? SummaryViewController
        systemUnderTest.loadView()


    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        systemUnderTest = nil
        coreDataServiceMock = nil
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
    

}
