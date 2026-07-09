import Foundation
import XCTest

@testable import zosconnectforswift

final class ServiceTests: XCTestCase {
    let zosConnect = ZosConnect(uri: "http://zosconnectmock.mybluemix.net")

    func testGetStatus() {
        let expectation = self.expectation(description: "getStatus")
        zosConnect.getService("dateTimeService") { result in
            result.result!.getStatus { result in
                XCTAssertEqual(result.result, .STARTED)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 10)
    }

    func testStart() {
        let expectation = self.expectation(description: "start")
        zosConnect.getService("dateTimeService") { result in
            result.result!.start { result in
                XCTAssertEqual(result.result, .STARTED)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 10)
    }

    func testStop() {
        let expectation = self.expectation(description: "stop")
        zosConnect.getService("dateTimeService") { result in
            result.result!.stop { result in
                XCTAssertEqual(result.result, .STOPPED)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 10)
    }

    func testGetRequestSchema() {
        let expectation = self.expectation(description: "getRequestSchema")
        zosConnect.getService("dateTimeService") { result in
            result.result!.getRequestSchema { result in
                XCTAssertNotNil(result.result)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 10)
    }

    func testGetResponseSchema() {
        let expectation = self.expectation(description: "getResponseSchema")
        zosConnect.getService("dateTimeService") { result in
            result.result!.getResponseSchema { result in
                XCTAssertNotNil(result.result)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 10)
    }

    func testInvoke() {
        let expectation = self.expectation(description: "invoke")
        zosConnect.getService("dateTimeService") { result in
            result.result!.invoke(nil) { result in
                XCTAssertEqual(result.statusCode, 200)
                XCTAssertNotNil(result.result)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 10)
    }
}