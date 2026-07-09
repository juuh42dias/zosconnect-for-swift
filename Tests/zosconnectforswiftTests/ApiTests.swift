import Foundation
import XCTest

@testable import zosconnectforswift

final class ApiTests: XCTestCase {
    let zosConnect = ZosConnect(uri: "http://zosconnectmock.mybluemix.net")

    func testGetApiDoc() {
        let expectation = self.expectation(description: "getApiDoc")
        zosConnect.getApi("healthApi") { result in
            result.result!.getApiDoc("swagger") { swagger in
                XCTAssertNotNil(swagger)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 10)
    }

    func testGetUnknownApiDoc() {
        let expectation = self.expectation(description: "getUnknownApiDoc")
        zosConnect.getApi("healthApi") { result in
            result.result!.getApiDoc("raml") { doc in
                XCTAssertNil(doc)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 10)
    }

    func testInvoke() {
        let expectation = self.expectation(description: "invoke")
        zosConnect.getApi("healthApi") { result in
            result.result!.invoke("GET", resource: "/patient/12345", data: nil) { result in
                XCTAssertEqual(result.statusCode, 200)
                XCTAssertNotNil(result.result)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 10)
    }
}