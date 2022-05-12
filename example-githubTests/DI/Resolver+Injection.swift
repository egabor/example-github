//
//  Resolver+Injection.swift
//  example-githubTests
//
//  Created by Eszenyi Gábor on 2022. 04. 16..
//

import Foundation
import Resolver
import Logging

@testable import example_github

extension Resolver {
    static var unitTests: Resolver!

    static func resetUnitTestRegistrations() {
        Resolver.reset()
        Resolver.defaultScope = .shared

        Resolver.unitTests = .init(child: .main)
        Resolver.root = .unitTests

        Resolver.unitTests.register { MockUsersApi(baseUrl: baseUrl) }
            .implements(UsersApiProtocol.self)
            .scope(.shared)

        Resolver.unitTests.register { Logger(label: loggerLabel) }
            .scope(.shared)
    }
}
