//
//  PreviewUserListViewModel.swift
//  example-github
//
//  Created by Eszenyi Gábor on 2022. 04. 16..
//

import Combine

class PreviewUserListViewModel: UserListViewModelProtocol {

    var users: [UserViewData] = []
    var nextPageLoading: NextPageLoading = .disabled
    var mostRecentSearchText: String = ""

    var isEmpty: Bool {
        users.isEmpty
    }

    init(
        users: [UserViewData],
        nextPageLoading: NextPageLoading
    ) {
        self.users = users
        self.nextPageLoading = nextPageLoading
    }


    func loadNextPage() {}
    func retryNextPage() {}
}

extension PreviewUserListViewModel {

    public static let empty: PreviewUserListViewModel = .init(
        users: [],
        nextPageLoading: .disabled
    )

    public static let someItems: PreviewUserListViewModel = .init(
        users: .previewArray,
        nextPageLoading: .disabled
    )

    public static let someItemsWithNextPage: PreviewUserListViewModel = .init(
        users: .previewArray,
        nextPageLoading: .loading
    )
}
