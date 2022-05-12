//
//  UsersApiProtocol.swift
//  example-github
//
//  Created by Eszenyi Gábor on 2022. 04. 16..
//

import Foundation

public protocol UsersApiProtocol {

    func getUsers(for searchExpression: String, pageSize: Int, page: Int) async throws -> UsersResponse
}
