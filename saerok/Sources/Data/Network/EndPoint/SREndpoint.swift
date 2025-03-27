//
//  SRAPIEndpoint.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//

import Foundation

enum SREndpoint: Endpoint {
    var baseURL: String {
        return ""
    }
    
    var path: String {
        switch self {
        default: return ""
        }
    }
    
    var method: String {
        switch self {
        default: "GET"
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
