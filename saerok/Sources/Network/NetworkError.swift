//
//  NetworkError.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//

enum NetworkError: Error {
    case unknownError
    case clientError(Int)
    case serverError(Int)
    case decodingError(String) 
}
