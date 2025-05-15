//
//  SRNetworkService.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//

protocol SRNetworkService: DefaultNetworkService {
    func fetchBirdList(endpoint: SREndpoint) async throws -> [DTO.Bird]
    func fetchLocalSearchResult(endpoint: KakaoEndpoint) async throws -> DTO.KakaoSearchResponse
}

final class SRNetworkServiceImpl: DefaultNetworkService, SRNetworkService {
    func fetchBirdList(endpoint: SREndpoint) async throws -> [DTO.Bird] {
        let request = endpoint.createRequest()
        let response: DTO.BirdsResponse = try await provider.request(request)
        return response.birds
    }
    
    func fetchLocalSearchResult(endpoint: KakaoEndpoint) async throws -> DTO.KakaoSearchResponse {
        let request = endpoint.createRequest()
        let response: DTO.KakaoSearchResponse = try await provider.request(request)
        return response
    }
    
    func fetchAddressResult(endpoint: KakaoEndpoint) async throws -> DTO.KakaoAddressResponse {
        let request = endpoint.createRequest()
        let response: DTO.KakaoAddressResponse = try await provider.request(request)
        return response
    }
    
    func fetchKakaoAPIResult<T: Decodable>(endpoint: KakaoEndpoint) async throws -> T {
        let request = endpoint.createRequest()
        
        switch endpoint {
        case .address:
            guard T.self == DTO.KakaoAddressResponse.self else {
                throw NetworkError.unknownError
            }
            return try await provider.request(request)
            
        case .keyword:
            guard T.self == DTO.KakaoSearchResponse.self else {
                throw NetworkError.unknownError
            }
            return try await provider.request(request)
        }
    }
}
