//
//  PagerTests.swift
//  example-githubTests
//
//  Created by Eszenyi Gábor on 2022. 04. 15..
//

import XCTest
import Resolver

@testable import example_github

class PagerTests: XCTestCase {

    let defaultPageSize = 9

    override func setUpWithError() throws {
        Resolver.resetUnitTestRegistrations()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPager_hasNextPage_withDefaultValues_shouldReturnTrue() {
        let pager = Pager(size: defaultPageSize, page: 0)
        XCTAssertTrue(pager.hasNext)
    }

    func testPager_hasNextPage_whenTotalCountIsDifferentThanDefault_shouldReturnTrue() {
        var pager = Pager(size: defaultPageSize, page: 0)
        XCTAssertTrue(pager.hasNext)
        pager.page = pager.next
        XCTAssertFalse(pager.hasNext)
        pager.totalCount = 10
        XCTAssertTrue(pager.hasNext)
        pager.page = pager.next
        XCTAssertFalse(pager.hasNext)
    }
}
