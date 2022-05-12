//
//  BaseApi.swift
//  example-github
//
//  Created by Eszenyi Gábor on 2022. 04. 15..
//

import Foundation
import Combine
import Logging
import Resolver

enum BaseApiError: Error, LocalizedError {
    case unknown, apiError(reason: String, statusCode: Int?)
    case failedToDecodeError
    case invalidURLRequest
    case invalidHTTPURLResponse
    case unacceptableStatusCode(Int)
    case serializedError(ErrorResponse)

    var errorDescription: String? { // TODO: Localize these
        switch self {
        case .unknown:
            return "Unknown error"
        case .failedToDecodeError:
            return "Received an error from the server, but cannot decode it"
        case .invalidURLRequest:
            return "Invalid URL Request"
        case .invalidHTTPURLResponse:
            return "Invalid HTTPURLResponse"
        case .unacceptableStatusCode(let statusCode):
            return "Unacceptable Status Code: \(statusCode)"
        case .serializedError(let errorResponse):
            return errorResponse.message
        case .apiError(let reason, let statusCode):
            guard let statusCode = statusCode else { return reason }
            return "\(reason) (Status Code: \(statusCode))"
        }
    }
}

internal class BaseApi {

    var baseUrl: String
    var headers: [String: String] = [
        "accept": "application/vnd.github.v3+json" // TODO: Move to constants
    ]

    lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    @Injected var logger: Logger
    var cancellables = Set<AnyCancellable>()

    init(baseUrl: String) {
        self.baseUrl = baseUrl
    }

    private func networkRequestPublisher<D: Decodable>(with requestData: NetworkRequest) -> AnyPublisher<D, Error> {
        guard let urlRequest = try? requestData.asURLRequest() else {
            return Fail(error: BaseApiError.invalidURLRequest)
                .eraseToAnyPublisher()
        }
        return URLSession
            .shared
            .dataTaskPublisher(for: urlRequest)
            .tryMap { [weak self] element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse else { throw BaseApiError.invalidHTTPURLResponse }

                // TODO: Consider to handle status codes between 300...399
                guard 200...299 ~= httpResponse.statusCode else {
                    guard let errorString = String(data: element.data, encoding: .utf8) else {
                        self?.logger.error("[OTHER ERROR] ⬇️⚠️: UNKNOWN DATA: \(element.data)")
                        throw BaseApiError.failedToDecodeError
                    }

                    var errorTypeIndicator = "❓"
                    if (400...499).contains(httpResponse.statusCode) {
                        errorTypeIndicator = "❌"
                    } else if (500..<599).contains(httpResponse.statusCode) {
                        errorTypeIndicator = "💣"
                    }
                    self?.logger.error("        [URL] ⬇️\(errorTypeIndicator): [\(requestData.method.rawValue)] \(requestData.unsafeURL.description)")
                    self?.logger.error("[STATUS CODE] ⬇️\(errorTypeIndicator): [\(httpResponse.statusCode)]")
                    self?.logger.error("      [ERROR] ⬇️\(errorTypeIndicator): \(errorString)")
                    guard let error = try? self?.decoder.decode(ErrorResponse.self, from: element.data) else {
                        throw BaseApiError.unacceptableStatusCode(httpResponse.statusCode)
                    }
                    throw BaseApiError.serializedError(error)
                }

                self?.logger.debug("        [URL] ⬇️✅: [\(requestData.method.rawValue)] \(requestData.unsafeURL.description)")
                self?.logger.debug("[STATUS CODE] ⬇️✅: [\(httpResponse.statusCode)]")
                if let responseString = String(data: element.data, encoding: .utf8) {
                    self?.logger.debug("   [RESPONSE] ⬇️✅: \(responseString)")
                }
                return element.data
            }
            .mapError { [weak self] error -> BaseApiError in
                if let error = error as? BaseApiError {
                    self?.logger.error("       [TYPE] ⬇️  : \(error)")
                    return error
                } else {
                    self?.logger.error("[OTHER ERROR] ⬇️⚠️: \(error.localizedDescription)")
                    return BaseApiError.apiError(reason: error.localizedDescription, statusCode: nil)
                }
            }
            .decode(type: D.self, decoder: decoder)
            .eraseToAnyPublisher()
    }

    private func asyncNetworkRequest<D: Decodable>(with requestData: NetworkRequest) async throws -> D {
        try await withCheckedThrowingContinuation { continuation in
            networkRequestPublisher(with: requestData)
                .sink(
                    receiveCompletion: { [weak self] completion in self?.handleCompletion(completion, continuation) },
                    receiveValue: { [weak self] value in self?.handleValue(value, continuation) }
                )
                .store(in: &cancellables)
        }
    }

    func buildRequest<D: Decodable>(with requestData: NetworkRequest) async throws -> D {
        do {
            return try await asyncNetworkRequest(with: requestData)
        } catch let error as NetworkRequestError {
            logger.error("NetworkRequestError: \(error.localizedDescription)")
            throw BaseApiError.apiError(reason: error.localizedDescription, statusCode: nil)
        } catch let error as BaseApiError {
            throw error
        } catch let error {
            logger.error("Unknown Error: \(error.localizedDescription)")
            throw BaseApiError.unknown
        }
    }

    // MARK: Handlers

    private func handleCompletion<D: Decodable, E: Error>(_ completion: Subscribers.Completion<E>, _ continuation: CheckedContinuation<D, E>) {
        if case .failure(let error) = completion {
            continuation.resume(throwing: error)
        }
    }

    private func handleValue<D: Decodable, E: Error>(_ value: D, _ continuation: CheckedContinuation<D, E>) {
        continuation.resume(returning: value)
    }
}
