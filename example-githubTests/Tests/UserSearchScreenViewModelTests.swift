//
//  UserSearchScreenViewModelTests.swift
//  example-githubTests
//
//  Created by Eszenyi Gábor on 2022. 04. 16..
//

import XCTest
import Combine
import Resolver

@testable import example_github

class UserSearchScreenViewModelTests: XCTestCase {

    @LazyInjected private var usersApi: MockUsersApi
    private var subscriptions: Set<AnyCancellable>!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        continueAfterFailure = false

        subscriptions = []
        Resolver.resetUnitTestRegistrations()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitialState() {
        let viewModel = UserSearchScreenViewModel()

        XCTAssertTrue(viewModel.isEmpty)
        XCTAssertTrue(viewModel.isSearchDisabled)
        XCTAssertFalse(viewModel.isSearchFieldDisabled)
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertEqual(viewModel.nextPageLoading, .disabled)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.showError)
        XCTAssertFalse(viewModel.showToast)
    }

    func testPreSearchState() {
        let searchText = "test"
        let viewModel = UserSearchScreenViewModel()
        viewModel.searchText = searchText

        XCTAssertTrue(viewModel.isEmpty)
        XCTAssertFalse(viewModel.isSearchDisabled)
        XCTAssertFalse(viewModel.isSearchFieldDisabled)
        XCTAssertEqual(viewModel.searchText, searchText)
        XCTAssertEqual(viewModel.nextPageLoading, .disabled)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.showError)
        XCTAssertFalse(viewModel.showToast)
    }

    func testInSearchState() {
        let searchText = "test"
        let viewModel = UserSearchScreenViewModel()
        viewModel.searchText = searchText
        usersApi.usersMockFileType = .successAllItems

        let loadingStarted = self.expectation(description: "Loading did start.")

        viewModel.$isLoading
            .dropFirst()
            .first()
            .receive(on: DispatchQueue.main)
            .sink { result in
                loadingStarted.fulfill()
            }
            .store(in: &subscriptions)

        let firstPageOfUsers = self.expectation(description: "Users did load.")

        viewModel.$users
            .dropFirst()
            .first()
            .receive(on: DispatchQueue.main)
            .sink { result in
                firstPageOfUsers.fulfill()
            }
            .store(in: &subscriptions)

        viewModel.search()

        wait(for: [loadingStarted], timeout: 10)

        XCTAssertTrue(viewModel.isEmpty)
        XCTAssertTrue(viewModel.isSearchDisabled)
        XCTAssertTrue(viewModel.isSearchFieldDisabled)
        XCTAssertEqual(viewModel.searchText, searchText)
        XCTAssertEqual(viewModel.nextPageLoading, .disabled)
        XCTAssertTrue(viewModel.isLoading)
        XCTAssertFalse(viewModel.showError)
        XCTAssertFalse(viewModel.showToast)

        wait(for: [firstPageOfUsers], timeout: 10)

        XCTAssertFalse(viewModel.isEmpty)
        XCTAssertTrue(viewModel.isSearchDisabled)
        XCTAssertFalse(viewModel.isSearchFieldDisabled)
        XCTAssertEqual(viewModel.searchText, searchText)
        XCTAssertEqual(viewModel.nextPageLoading, .disabled)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.showError)
        XCTAssertFalse(viewModel.showToast)
    }

    func testPostSearchState_whenNumberOfPagesIs1() {
        let searchText = "test"
        let viewModel = UserSearchScreenViewModel()
        viewModel.searchText = searchText
        usersApi.usersMockFileType = .successAllItems

        let firstPageOfUsers = self.expectation(description: "Users did load.")

        viewModel.$users
            .dropFirst()
            .first()
            .receive(on: DispatchQueue.main)
            .sink { result in
                firstPageOfUsers.fulfill()
            }
            .store(in: &subscriptions)

        viewModel.search()

        wait(for: [firstPageOfUsers], timeout: 10)

        XCTAssertFalse(viewModel.isEmpty)
        XCTAssertTrue(viewModel.isSearchDisabled)
        XCTAssertFalse(viewModel.isSearchFieldDisabled)
        XCTAssertEqual(viewModel.searchText, searchText)
        XCTAssertEqual(viewModel.nextPageLoading, .disabled)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.showError)
        XCTAssertFalse(viewModel.showToast)
    }

    func test_whenSearchTextIsEmpty_shouldNotStartSearch() {
        let searchText = ""
        let viewModel = UserSearchScreenViewModel()
        viewModel.searchText = searchText
        usersApi.usersMockFileType = .successAllItems

        let performSearch = self.expectation(description: "Perform search.")

        viewModel.search()

        DispatchQueue.main.async {
            performSearch.fulfill()
        }

        wait(for: [performSearch], timeout: 10)

        XCTAssertFalse(viewModel.isLoading)
    }

    func test_whenSearchTextIsNotEmpty_shouldStartSearch() {
        let searchText = "test"
        let viewModel = UserSearchScreenViewModel()
        viewModel.searchText = searchText
        usersApi.usersMockFileType = .successAllItems

        let searchDidStart = self.expectation(description: "Search did start.")

        viewModel.search()

        DispatchQueue.main.async {
            searchDidStart.fulfill()
        }

        wait(for: [searchDidStart], timeout: 10)

        XCTAssertTrue(viewModel.isLoading)
    }

    func testPostSearchState_whenNumberOfPagesIsMoreThan1() {
        let searchText = "test"
        let viewModel = UserSearchScreenViewModel()
        viewModel.searchText = searchText
        usersApi.usersMockFileType = .successFirstPage

        let firstPageOfUsers = self.expectation(description: "Users did load.")

        viewModel.$users
            .dropFirst()
            .first()
            .receive(on: DispatchQueue.main)
            .sink { result in
                firstPageOfUsers.fulfill()
            }
            .store(in: &subscriptions)

        viewModel.search()

        wait(for: [firstPageOfUsers], timeout: 10)

        XCTAssertFalse(viewModel.isEmpty)
        XCTAssertTrue(viewModel.isSearchDisabled)
        XCTAssertFalse(viewModel.isSearchFieldDisabled)
        XCTAssertEqual(viewModel.searchText, searchText)
        XCTAssertEqual(viewModel.nextPageLoading, .loading)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.showError)
        XCTAssertFalse(viewModel.showToast)
    }

    func test_loadSecondPage() {
        let searchText = "test"
        let viewModel = UserSearchScreenViewModel()
        viewModel.searchText = searchText
        usersApi.usersMockFileType = .successFirstPage

        let firstPageOfUsers = self.expectation(description: "Users did load. Page 1")

        viewModel.$users
            .dropFirst()
            .first()
            .receive(on: DispatchQueue.main)
            .sink { result in
                firstPageOfUsers.fulfill()
            }
            .store(in: &subscriptions)

        viewModel.search()

        wait(for: [firstPageOfUsers], timeout: 10)

        let secondPageOfUsers = self.expectation(description: "Users did load. Page 2")

        viewModel.$users
            .dropFirst()
            .first()
            .receive(on: DispatchQueue.main)
            .sink { result in
                secondPageOfUsers.fulfill()
            }
            .store(in: &subscriptions)

        viewModel.loadNextPage()

        wait(for: [secondPageOfUsers], timeout: 10)

        XCTAssertFalse(viewModel.isEmpty)
        XCTAssertTrue(viewModel.isSearchDisabled)
        XCTAssertFalse(viewModel.isSearchFieldDisabled)
        XCTAssertEqual(viewModel.searchText, searchText)
        XCTAssertEqual(viewModel.nextPageLoading, .loading)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.showError)
        XCTAssertFalse(viewModel.showToast)
    }

    func test_failureWhenLoadingFirstPage() {
        let searchText = "test"
        let viewModel = UserSearchScreenViewModel()
        viewModel.searchText = searchText
        usersApi.usersMockFileType = .failure

        let errorAtFirstPage = self.expectation(description: "Error when loading Page 1")

        viewModel.$showError
            .dropFirst()
            .first()
            .receive(on: DispatchQueue.main)
            .sink { result in
                errorAtFirstPage.fulfill()
            }
            .store(in: &subscriptions)

        viewModel.search()

        wait(for: [errorAtFirstPage], timeout: 10)

        XCTAssertTrue(viewModel.isEmpty)
        XCTAssertFalse(viewModel.isSearchDisabled)
        XCTAssertFalse(viewModel.isSearchFieldDisabled)
        XCTAssertEqual(viewModel.searchText, searchText)
        XCTAssertEqual(viewModel.nextPageLoading, .disabled)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.showError)
        XCTAssertFalse(viewModel.showToast)
    }

    func test_failureWhenLoadingSecondPage() {
        let searchText = "test"
        let viewModel = UserSearchScreenViewModel()
        viewModel.searchText = searchText
        usersApi.usersMockFileType = .successFirstPage

        let firstPageOfUsers = self.expectation(description: "Users did load. Page 1")

        viewModel.$users
            .dropFirst()
            .first()
            .receive(on: DispatchQueue.main)
            .sink { result in
                firstPageOfUsers.fulfill()
            }
            .store(in: &subscriptions)

        viewModel.search()

        wait(for: [firstPageOfUsers], timeout: 10)

        usersApi.usersMockFileType = .failure

        let errorAtSecondPage = self.expectation(description: "Error when loading Page 2")

        viewModel.$showToast
            .dropFirst()
            .first()
            .receive(on: DispatchQueue.main)
            .sink { result in
                errorAtSecondPage.fulfill()
            }
            .store(in: &subscriptions)

        viewModel.loadNextPage()

        wait(for: [errorAtSecondPage], timeout: 10)

        XCTAssertFalse(viewModel.isEmpty)
        XCTAssertTrue(viewModel.isSearchDisabled)
        XCTAssertFalse(viewModel.isSearchFieldDisabled)
        XCTAssertEqual(viewModel.searchText, searchText)
        XCTAssertEqual(viewModel.nextPageLoading, .disabled)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.showError)
        XCTAssertTrue(viewModel.showToast)
    }
}
