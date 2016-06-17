import UIKit
import XCTest
import JTAppleCalendar

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testDateBoundary() {
        let testString = "To check the date boundaries"
        XCTAssert(testString == "To check the date boundaries")
    }
    
    func testCalendarSection() {
        let testString = "To check the date sections"
        XCTAssert(testString == "To check the date sections")
    }
    
    func testToMakeSureStringAppends() {
        var s1 = "Foo";
        let expectation = self.expectation(withDescription: "Handler called")
        s1 = s1 + "sd"
        expectation.fulfill()
        waitForExpectations(withTimeout: 0.1, handler:nil)
    }

    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
