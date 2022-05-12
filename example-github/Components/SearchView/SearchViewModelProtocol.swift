//
//  SearchViewModelProtocol.swift
//  example-github
//
//  Created by Eszenyi Gábor on 2022. 04. 16..
//

import Combine

protocol SearchViewModelProtocol: ObservableObject {

    var searchText: String { get set }
    var isSearchFieldDisabled: Bool { get }
    var isSearchDisabled: Bool { get }

    func search()
    func loadNextPage()
    func clearSearch()
}

extension SearchViewModelProtocol {

    var showsClearButton: Bool {
        !searchText.isEmpty
    }

    func clearSearch() {
        searchText = ""
    }
}

extension SearchViewModelProtocol {

    var localizedSearchFieldPlaceholder: String {
        String.userSearchScreenSearchTextFieldPlaceholder
    }

    var localizedSearchButtonTitle: String {
        String.userSearchScreenSearchButtonTitle
    }
}
