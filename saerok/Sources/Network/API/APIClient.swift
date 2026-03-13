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
        
        if T.self == EmptyResponse.self {
            return EmptyResponse() as! T
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
        
        if T.self == EmptyResponse.self {
            return (EmptyResponse() as! T, httpResponse.statusCode)
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
        case 400..<500:
            return NetworkError.clientError(statusCode)
        case 500..<600:
            return NetworkError.serverError(statusCode)
        default:
            return NetworkError.unknownError
        }
    }
}

private extension APIClient {
    func logRequest(_ request: URLRequest) {
        print("🚀 [REQUEST]")
        print("URL:", request.url?.absoluteString ?? "")
        print("Method:", request.httpMethod ?? "")
        
        if let headers = request.allHTTPHeaderFields {
            print("Headers:", headers)
        }
        
        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            print("Body:", bodyString)
        }
        
        print("-----------------------")
    }
    
    func logResponse(data: Data, response: HTTPURLResponse) {
        print("📦 [RESPONSE]")
        print("StatusCode:", response.statusCode)
        print("URL:", response.url?.absoluteString ?? "")
        print("Headers:", response.allHeaderFields)
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Body:", jsonString)
        } else {
            print("⚠️ Body 디코딩 불가")
        }
        
        print("-----------------------")
    }
}
