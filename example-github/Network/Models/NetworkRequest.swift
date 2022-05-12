//
//  NetworkRequest.swift
//  example-github
//
//  Created by Eszenyi Gábor on 2022. 04. 15..
//

import Foundation

enum NetworkRequestError: Error {
    case invalidURL
}

enum HTTPMethod: String {
    case get = "GET"
}

struct NetworkRequest {
    let baseUrl: String
    let path: String
    let method: HTTPMethod
    let headers: [String: String]?
    let queryItems: [URLQueryItem]?
    let body: Data?

    var urlComponents: URLComponents? {
        var urlComponents = URLComponents(string: baseUrl)
        urlComponents?.path.append(path)
        urlComponents?.queryItems = queryItems
        return urlComponents
    }

    var url: URL? {
        urlComponents?.url
    }

    var unsafeURL: URL {
        urlComponents!.url!
    }

    init(_ baseUrl: String,
         _ path: String,
         _ method: HTTPMethod,
         _ headers: [String: String]? = nil,
         queryItems: [URLQueryItem]? = nil,
         body: Data? = nil) {
        self.baseUrl = baseUrl
        self.path = path
        self.method = method
        self.headers = headers
        self.queryItems = queryItems
        self.body = body
    }

    public func asURLRequest() throws -> URLRequest {
        guard let url = url else { throw NetworkRequestError.invalidURL }

        var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 60.0)

        // Set the HTTP method
        urlRequest.httpMethod = method.rawValue

        // Set Headers
        urlRequest.allHTTPHeaderFields = headers

        // Set Body
        if let body = body {
            urlRequest.httpBody = body
        }

        return urlRequest
    }
}
