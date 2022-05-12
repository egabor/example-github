//
//  MockUsersApi.swift
//  example-githubTests
//
//  Created by Eszenyi Gábor on 2022. 04. 16..
//

import Foundation
@testable import example_github

enum UsersMockFileType: String {
    case successAllItems = "MockUsersSuccessAllItems.json"
    case successFirstPage = "MockUsersSuccessFirstPage.json"
    case failure
}

internal class MockUsersApi: BaseApi, UsersApiProtocol {
    var usersMockFileType: UsersMockFileType?

    func getUsers(for searchExpression: String, pageSize: Int, page: Int) async throws -> UsersResponse {
        guard usersMockFileType != .failure else {
            throw BaseApiError.apiError(reason: "Error while loading users.", statusCode: nil)
        }
        guard let fileName = usersMockFileType?.rawValue,
              let url = Bundle(for: type(of: self)).url(forResource: fileName, withExtension: nil),
              let data = try? Data(contentsOf: url),
              let result = try? decoder.decode(UsersResponse.self, from: data)
        else {
            return UsersResponse.init(totalCount: 0, incompleteResults: false, items: [])
        }
        return result
    }
}
