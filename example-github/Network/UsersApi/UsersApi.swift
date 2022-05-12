//
//  UsersApi.swift
//  example-github
//
//  Created by Eszenyi Gábor on 2022. 04. 15..
//

import Foundation

internal class UsersApi: BaseApi, UsersApiProtocol {

    func getUsers(for searchExpression: String, pageSize: Int, page: Int) async throws -> UsersResponse {
        let queryItems: [URLQueryItem] = [
            .init(name: "q", value: searchExpression),
            .init(name: "order", value: "asc"),
            .init(name: "per_page", value: "\(pageSize)"),
            .init(name: "page", value: "\(page)"),
            .init(name: " in:login", value: nil)
        ]

        let request = NetworkRequest(baseUrl, "search/users", .get, headers, queryItems: queryItems)
        return try await buildRequest(with: request)
    }
}
