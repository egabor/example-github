//
//  User.swift
//  example-github
//
//  Created by Eszenyi Gábor on 2022. 04. 16..
//

import Foundation

public struct User: Decodable {
    public let id: Int
    public let login: String
    public let type: String
    public let avatarUrl: String
}
