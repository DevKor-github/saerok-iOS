//
//  SRAPIEndpoint.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//


import Foundation

enum SREndpoint: Endpoint {
    case fullSync
    
    var baseURL: String {
        return "http://3.34.90.203:8080/api/"
    }
    
    var path: String {
        switch self {
        case .fullSync: "v1/birds/full-sync"
        }
    }
    
    var method: String {
        switch self {
        case .fullSync: "GET"
        }
    }
    
    var headers: [String: String]? {
        return nil
    }
    
    var requestBody: Data? {
        switch self {
        default: return nil
        }
    }
    
    var queryItems: [String: String]? {
        switch self {
        default: return nil
        }
    }
}
