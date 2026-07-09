import Foundation
import XCTest

@testable import zosconnectforswift

final class ZosConnectTests: XCTestCase {
    let zosConnect = ZosConnect(uri: "http://zosconnectmock.mybluemix.net")

    func testGetServices() {
        let expectation = self.expectation(description: "getServices")
        zosConnect.getServices { result in
            if let error = result.error {
                XCTFail(String(describing: error))
            } else if let services = result.result {
                XCTAssert(services[0] == "dateTimeService")
            } else {
                XCTFail("No data returned from call")
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10)
    }

    func testGetService() {
        let expectation = self.expectation(description: "getService")
        zosConnect.getService("dateTimeService") { result in
            XCTAssertNotNil(result.result)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10)
    }

    func testGetApis() {
        let expectation = self.expectation(description: "getApis")
        zosConnect.getApis { result in
            if let error = result.error {
                XCTFail(String(describing: error))
            } else if let apis = result.result {
                XCTAssertEqual(apis.first, "healthApi")
            } else {
                XCTFail("No data returned from call")
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10)
    }

    func testGetApi() {
        let expectation = self.expectation(description: "getApi")
        zosConnect.getApi("healthApi") { result in
            XCTAssertNotNil(result.result)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10)
    }
}