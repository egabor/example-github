//
//  Pager.swift
//  example-github
//
//  Created by Eszenyi Gábor on 2022. 04. 16..
//

import Foundation

struct Pager {

    private(set) var size: Int
    var page: Int
    var totalCount: Int = 0

    var hasNext: Bool {
        0 < totalCount - (page * size) || page == 0
    }

    var next: Int {
        guard hasNext else { return page }
        return page + 1
    }

    init(
        size: Int,
        page: Int,
        totalCount: Int = 0
    ) {
        self.size = size
        self.page = page
        self.totalCount = totalCount
    }
}
