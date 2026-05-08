//
//  Endpoint.swift
//  IssueTrackerApp
//
//  Created by HanSeung on 10/2/24.
//

import Foundation

protocol Endpoint {
    /// API 요청을 위한 기본 URL
    var baseURL: String { get }
    
    /// API 요청의 경로
    var path: String { get }
    
    /// HTTP 요청 메서드 (GET, POST, PUT 등)
    var method: HTTPMethod { get }
    
    /// HTTP 헤더에 추가할 키-값 쌍
    var headers: [String: String]? { get }
    
    /// HTTP 요청 본문에 담길 데이터
    var requestBody: Data? { get }
    
    var queryItems: [String:String]? { get }
    
    /// 엔드포인트 정보로 URLRequest를 생성
    /// - Returns: URLRequest 객체
    func createRequest() -> URLRequest
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
}

extension Endpoint {
    func createRequest() -> URLRequest {
        guard var components = URLComponents(string: baseURL + path) else {
            fatalError("잘못된 URL — baseURL: \(baseURL), path: \(path)")
        }

        if let queryItems = queryItems {
            components.queryItems = queryItems.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let url = components.url else {
            fatalError("URL 생성 실패 — baseURL: \(baseURL), path: \(path)")
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if let requestBody = requestBody {
            request.httpBody = requestBody
        }
        
        if let headers = headers {
            headers.forEach { key, value in
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        return request
    }
}
