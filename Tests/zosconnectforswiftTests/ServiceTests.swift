import Foundation
import XCTest

@testable import zosconnectforswift

final class ServiceTests: XCTestCase {
    let zosConnect = ZosConnect(uri: "http://zosconnectmock.mybluemix.net")

    func testGetStatus() {
        let expectation = self.expectation(description: "getStatus")
        zosConnect.getService("dateTimeService") { result in
            guard let service = result.result else {
                XCTFail("Service not available (integration test requires mock server)")
                expectation.fulfill()
                return
            }
            service.getStatus { result in
                XCTAssertEqual(result.result, .STARTED)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 10)
    }

    func testStart() {
        let expectation = self.expectation(description: "start")
        zosConnect.getService("dateTimeService") { result in
            guard let service = result.result else {
                XCTFail("Service not available (integration test requires mock server)")
                expectation.fulfill()
                return
            }
            service.start { result in
                XCTAssertEqual(result.result, .STARTED)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 10)
    }

    func testStop() {
        let expectation = self.expectation(description: "stop")
        zosConnect.getService("dateTimeService") { result in
            guard let service = result.result else {
                XCTFail("Service not available (integration test requires mock server)")
                expectation.fulfill()
                return
            }
            service.stop { result in
                XCTAssertEqual(result.result, .STOPPED)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 10)
    }

    func testGetRequestSchema() {
        let expectation = self.expectation(description: "getRequestSchema")
        zosConnect.getService("dateTimeService") { result in
            guard let service = result.result else {
                XCTFail("Service not available (integration test requires mock server)")
                expectation.fulfill()
                return
            }
            service.getRequestSchema { result in
                XCTAssertNotNil(result.result)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 10)
    }

    func testGetResponseSchema() {
        let expectation = self.expectation(description: "getResponseSchema")
        zosConnect.getService("dateTimeService") { result in
            guard let service = result.result else {
                XCTFail("Service not available (integration test requires mock server)")
                expectation.fulfill()
                return
            }
            service.getResponseSchema { result in
                XCTAssertNotNil(result.result)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 10)
    }

    func testInvoke() {
        let expectation = self.expectation(description: "invoke")
        zosConnect.getService("dateTimeService") { result in
            guard let service = result.result else {
                XCTFail("Service not available (integration test requires mock server)")
                expectation.fulfill()
                return
            }
            service.invoke(nil) { result in
                XCTAssertEqual(result.statusCode, 200)
                XCTAssertNotNil(result.result)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 10)
    }
}