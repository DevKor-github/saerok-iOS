//
//  NetworkError.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//

enum NetworkError: Error {
    case decodingError
    case clientError
    case redirectError
    case serverError
    case unknownError
}
