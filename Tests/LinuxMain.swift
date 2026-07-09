import XCTest

XCTMain([
    testCase(ZosConnectTests.allTests),
    testCase(ServiceTests.allTests),
    testCase(ApiTests.allTests),
])