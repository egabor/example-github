//
//  UserListViewModelProtocol.swift
//  example-github
//
//  Created by Eszenyi Gábor on 2022. 04. 16..
//

import Foundation
import Combine

protocol UserListViewModelProtocol: ObservableObject {

    var users: [UserViewData] { get set }
    var nextPageLoading: NextPageLoading { get set }
    var mostRecentSearchText: String { get set }
    var isEmpty: Bool { get }

    func loadNextPage()
    func retryNextPage()
}

extension UserListViewModelProtocol {

    var localizedEmptyListText: String {
        mostRecentSearchText.isEmpty ?
        String.userSearchScreenUserListInitialStateTitle :
        String(format: NSLocalizedString(.userSearchScreenUserListNoResultsStateTitle, comment: ""), mostRecentSearchText)
    }

    var localizedRetryButtonTitle: String {
        String.userSearchScreenUserListButtonRetryTitle
    }
}
