//
//  ErrorResponse.swift
//  example-github
//
//  Created by Eszenyi Gábor on 2022. 04. 15..
//

import Foundation

struct ErrorResponse: Decodable {
    let message: String
    let documentationUrl: String?
}
