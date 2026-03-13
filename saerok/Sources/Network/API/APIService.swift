//
//  NetworkService.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//

import Foundation

protocol APIService {
    /// 주어진 endpoint를 통해 URLRequest를 생성하고 요청을 수행
    /// - Parameters:
    ///   - endpoint: URLRequest를 생성할 APIEnpoint 객체
    /// - Returns: 요청에 대한 결과를 포함하는 `async`로, 성공 시 디코딩된 데이터를 반환하고, 실패 시 오류를 반환
    func request<T: Decodable>(endpoint: Endpoint) async throws -> T
    func requestWithStatus<T: Decodable>(endpoint: Endpoint) async throws -> (T, Int)
}

final class DefaultAPIService: APIService {
    let apiClient = DefaultAPIClient()

    init() {}

    func request<T: Decodable>(endpoint: Endpoint) async throws -> T {
        let request = endpoint.createRequest()
        return try await apiClient.request(request)
    }
    
    func requestWithStatus<T: Decodable>(endpoint: Endpoint) async throws -> (T, Int) {
        let request = endpoint.createRequest()
        return try await apiClient.requestWithStatus(request)
    }
}
