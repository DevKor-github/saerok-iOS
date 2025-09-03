//
//  KakaoEndpoint.swift
//  saerok
//
//  Created by HanSeung on 5/8/25.
//


import Foundation

enum KakaoEndpoint: Endpoint {
    case keyword(_ keyword: String)
    case address(lng: Double, lat: Double)
}

extension KakaoEndpoint {
    private var apiKey: String { Bundle.main.kakaoAPIKey }
    
    var baseURL: String {
        return "https://dapi.kakao.com/v2/"
    }
    
    var path: String {
        switch self {
        case .keyword:
            return "local/search/keyword.json"
        case .address:
            return "local/geo/coord2address.json}"
        }
    }
    
    var method: String {
        switch self {
        case .keyword, .address:
            return "GET"
        }
    }
    
    var headers: [String: String]? {
        return [
            "Authorization": "KakaoAK \(apiKey)"
        ]
    }
    
    var requestBody: Data? {
        return nil
    }
    
    var queryItems: [String: String]? {
        switch self {
        case .keyword(let keyword):
            return [
                "query": keyword,
                "size": "5",
            ]
        case .address(let longtitude, let latitude):
            return [
                "x": String(latitude),
                "y": String(longtitude)
            ]
        }
    }
}

extension KakaoEndpoint {
    var expectedResponseType: Decodable.Type {
            switch self {
            case .address:
                return DTO.KakaoAddressResponse.self
            case .keyword:
                return DTO.KakaoSearchResponse.self
            }
        }
}
