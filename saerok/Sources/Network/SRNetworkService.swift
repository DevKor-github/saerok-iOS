//
//  SRNetworkService.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//

protocol SRNetworkService: DefaultNetworkService {
    func performSRRequest<T: Decodable>(_ endpoint: SREndpoint) async throws -> T
    func performKakaoRequest<T: Decodable>(_ endpoint: KakaoEndpoint) async throws -> T
}

final class SRNetworkServiceImpl: DefaultNetworkService, SRNetworkService {
    func performSRRequest<T: Decodable>(_ endpoint: SREndpoint) async throws -> T {
        let request = endpoint.createRequest()

        guard T.self == endpoint.expectedResponseType else {
            throw NetworkError.typeError
        }

        return try await provider.request(request)
    }
    
    func performKakaoRequest<T: Decodable>(_ endpoint: KakaoEndpoint) async throws -> T {
        let request = endpoint.createRequest()

        guard T.self == endpoint.expectedResponseType else {
            throw NetworkError.unknownError
        }

        return try await provider.request(request)
    }
}
