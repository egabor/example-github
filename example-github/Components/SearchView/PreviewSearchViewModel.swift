//
//  PreviewSearchViewModel.swift
//  example-github
//
//  Created by Eszenyi Gábor on 2022. 04. 16..
//

import Combine

class PreviewSearchViewModel: SearchViewModelProtocol {

    var searchText: String = ""
    private (set) var isSearchFieldDisabled: Bool = false
    private (set) var isSearchDisabled: Bool = false

    init() {}

    func search() {}
    func loadNextPage() {}
    func clearSearch() {}
}
