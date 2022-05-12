//
//  UserSearchScreenViewModel.swift
//  example-github
//
//  Created by Eszenyi Gábor on 2022. 04. 16..
//

import Foundation
import Combine
import Logging
import Resolver

typealias UserSearchProtocol = SearchViewModelProtocol & UserListViewModelProtocol & ErrorCapable & LoadingCapable & ToastCapable

class UserSearchScreenViewModel: UserSearchProtocol {

    let defaultPageSize = 9

    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var users: [UserViewData] = []
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""
    @Published var nextPageLoading: NextPageLoading = .disabled

    internal var mostRecentSearchText: String = ""
    private lazy var pager: Pager = {
        return .init(size: defaultPageSize, page: 0)
    }()
    internal var toastTimer: Timer?

    var isSearchFieldDisabled: Bool {
        isLoading
    }

    var isSearchDisabled: Bool {
        isLoading || searchText == mostRecentSearchText
    }

    var isEmpty: Bool {
        users.isEmpty
    }

    @Injected private var logger: Logger
    @Injected var usersApi: UsersApiProtocol

    init() {
        logger.info("\(Self.self) initialized.")
        setupPublishers()
    }

    private func setupPublishers() {
        Publishers.CombineLatest3($users, $showError, $showToast).map { [weak self] (users, showError, showToast) -> NextPageLoading in
            guard let self = self else { return .disabled }
            switch self.nextPageLoading {
            case .retry: return self.nextPageLoading
            default: return self.getNextPageLoading(users, showError, showToast)
            }
        }
        .assign(to: &$nextPageLoading)
    }

    private func getNextPageLoading(_ users: [UserViewData], _ showError: Bool, _ showToast: Bool) -> NextPageLoading {
        switch (users.isEmpty, showError, showToast) {
        case (false, false, false) where pager.hasNext: return .loading
        default: return .disabled
        }
    }

    func search() {
        guard !searchText.isEmpty else {
            resetList()
            return
        }
        logger.info("Starting search with expression: \(searchText)")
        loadPage(1, for: searchText)
    }

    func loadNextPage() {
        logger.info("Checking for next page. (current: \(pager.page); totalCount: \(pager.totalCount); hasNext: \(pager.hasNext))")
        guard pager.hasNext else {
            logger.info("No next page. This is the last: \(pager.page) (totalCount: \(pager.totalCount))")
            return
        }
        logger.info("Loading next page: \(pager.page)")
        loadPage(pager.next, for: mostRecentSearchText)
    }

    func retryNextPage() {
        guard !showToast else { return }
        nextPageLoading = .loading
    }

    private func resetList() {
        mostRecentSearchText = searchText
        users = []
        pager = .init(size: defaultPageSize, page: 0)
        nextPageLoading = getNextPageLoading(users, showError, showToast)
    }

    func loadPage(_ page: Int = 1, for searchExpression: String) {
        let isFirstPage = page == 1
        if isFirstPage {
            setLoadingOnMain(to: true)
        }
        Task.init {
            do {
                let result = try await usersApi.getUsers(
                    for: searchExpression,
                    pageSize: pager.size,
                    page: page
                )
                logger.info("Page loaded: \(pager.page)")
                processUsers(response: result, overrideResults: isFirstPage)
            } catch let error {
                DispatchQueue.main.async { [self] in
                    handlePageLoadingError(error, isFirstPage: isFirstPage)
                }
            }
        }
    }

    private func processUsers(response: UsersResponse, overrideResults: Bool = false) {
        DispatchQueue.main.async { [self] in
            if overrideResults {
                pager = .init(
                    size: defaultPageSize,
                    page: 0,
                    totalCount: response.totalCount
                )
                mostRecentSearchText = searchText
                users = []
                setLoadingOnMain(to: false)
                nextPageLoading = getNextPageLoading(users, showError, showToast)
            }
            pager.page = pager.next
            users.append(contentsOf: getMappedUsers(from: response))
        }
    }

    private func getMappedUsers(from response: UsersResponse) -> [UserViewData] {
        response.items
            .map {
                .init(
                    login: $0.login,
                    type: $0.type.uppercased(),
                    avatarUrl: $0.avatarUrl
                )
            }
    }

    private func handlePageLoadingError(_ error: Error, isFirstPage: Bool) {
        logger.error("Error while getting page \(pager.page): \(error.localizedDescription)")
        if isFirstPage {
            showErrorOnMain(message: error.localizedDescription)
        } else {
            nextPageLoading = .retry
            showToastOnMain(message: error.localizedDescription)
        }
        setLoadingOnMain(to: false)
    }
}
