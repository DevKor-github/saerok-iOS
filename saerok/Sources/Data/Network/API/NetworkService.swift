//
//  NetworkService.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//

import Foundation

private protocol NetworkService {
    /// 주어진 endpoint를 통해 URLRequest를 생성하고 요청을 수행
    /// - Parameters:
    ///   - endpoint: URLRequest를 생성할 APIEnpoint 객체
    ///   - responseType: 응답 데이터를 디코딩할 타입
    /// - Returns: 요청에 대한 결과를 포함하는 `async`로, 성공 시 디코딩된 데이터를 반환하고, 실패 시 오류를 반환
    func request<T: Decodable>(endpoint: Endpoint, responseType: T.Type) async throws -> T
}

class DefaultNetworkService: NetworkService {
    let provider = Provider()

    init() {}

    func request<T: Decodable>(endpoint: Endpoint, responseType: T.Type) async throws -> T {
        let request = endpoint.createRequest()
        return try await provider.request(request)
    }
}
