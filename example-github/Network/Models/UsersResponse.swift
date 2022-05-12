//
//  UsersResponse.swift
//  example-github
//
//  Created by Eszenyi Gábor on 2022. 04. 15..
//

import Foundation

public struct UsersResponse: Decodable {
    public let totalCount: Int
    public let incompleteResults: Bool
    public let items: [User]
}
