//
//  Resolver+Injection.swift
//  example-github
//
//  Created by Eszenyi Gábor on 2022. 04. 16..
//

import Foundation
import Resolver
import Logging

extension Resolver: ResolverRegistering {

    static var baseUrl: String { "https://api.github.com/" }
    static var loggerLabel: String { "com.gaboreszenyi.example-github" }

    public static func registerAllServices() {
        register { UsersApi(baseUrl: baseUrl) }
            .implements(UsersApiProtocol.self)
            .scope(.shared)

        register { Logger(label: loggerLabel) }
            .scope(.shared)
    }
}
