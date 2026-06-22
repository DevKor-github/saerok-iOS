//
//  Provider.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//

import Foundation

struct EmptyResponse: Decodable {}

protocol APIClient {
    func request<T: Decodable>(_ request: URLRequest) async throws -> T
    func requestWithStatus<T: Decodable>(_ request: URLRequest) async throws -> (T, Int)
}

final class DefaultAPIClient: APIClient {
    private let defaultURLSession = URLSession(configuration: .default)
    private let decoder: JSONDecoder = .withFlexibleISO8601()
    
    func request<T: Decodable>(_ request: URLRequest) async throws -> T {
        #if DEBUG
        logRequest(request)
        #endif
        
        let (data, response) = try await defaultURLSession.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknownError
        }

        #if DEBUG
        logResponse(data: data, response: httpResponse)
        #endif

        guard 200..<300 ~= httpResponse.statusCode else {
            throw self.validateStatusCode(httpResponse.statusCode)
        }

        if let empty = EmptyResponse() as? T {
            return empty
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error.localizedDescription)
        }
    }
    
    func requestWithStatus<T: Decodable>(_ request: URLRequest) async throws -> (T, Int) {
        let (data, response) = try await defaultURLSession.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknownError
        }
        
        if !(200..<300).contains(httpResponse.statusCode) {
            throw self.validateStatusCode(httpResponse.statusCode)
        }

        if let empty = EmptyResponse() as? T {
            return (empty, httpResponse.statusCode)
        }
        
        do {
            let decoded = try decoder.decode(T.self, from: data)
            return (decoded, httpResponse.statusCode)
        } catch {
            throw NetworkError.decodingError(error.localizedDescription)
        }
    }
    
    func validateStatusCode(_ statusCode: Int) -> NetworkError {
        switch statusCode {
        case 401: return .unauthorized
        case 403: return .forbidden
        case 404: return .notFound
        case 429: return .rateLimited
        case 400..<500: return .clientError(statusCode)
        case 500..<600: return .serverError(statusCode)
        default:  return .unknownError
        }
    }
}

private extension APIClient {
    func logRequest(_ request: URLRequest) {
        var lines = ["🚀 [REQUEST]"]
        lines.append("URL: \(request.url?.absoluteString ?? "")")
        lines.append("Method: \(request.httpMethod ?? "")")

        if let headers = request.allHTTPHeaderFields {
            lines.append("Headers: \(headers)")
        }

        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            lines.append("Body: \(bodyString)")
        }

        // DEBUG 전용 컴파일 경로이므로 값을 그대로 노출(.public)한다.
        SRLog.network.debug("\(lines.joined(separator: "\n"), privacy: .public)")
    }

    func logResponse(data: Data, response: HTTPURLResponse) {
        var lines = ["📦 [RESPONSE]"]
        lines.append("StatusCode: \(response.statusCode)")
        lines.append("URL: \(response.url?.absoluteString ?? "")")
        lines.append("Headers: \(response.allHeaderFields)")

        if let jsonString = String(data: data, encoding: .utf8) {
            lines.append("Body: \(jsonString)")
        } else {
            lines.append("⚠️ Body 디코딩 불가")
        }

        SRLog.network.debug("\(lines.joined(separator: "\n"), privacy: .public)")
    }
}
