//
//  Provider.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//

import Foundation

final class Provider {
    private let defaultURLSession = URLSession(configuration: .default)
    private let decoder = JSONDecoder()
    
    init() { decoder.dateDecodingStrategy = .iso8601 }
    
    func request<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await defaultURLSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknownError
        }
        
        guard 200..<300 ~= httpResponse.statusCode else {
            throw self.validateStatusCode(httpResponse.statusCode)
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func validateStatusCode(_ statusCode: Int) -> Error {
        switch statusCode {
        default:
            return NetworkError.unknownError
        }
    }
}
