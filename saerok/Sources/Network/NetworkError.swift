//
//  NetworkError.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//


import Foundation

enum NetworkError: Error {
    case unknownError
    case clientError(Int)
    case serverError(Int)
    case decodingError(String)
    case typeError
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .clientError(let code):
            return "요청에 문제가 있습니다. (오류 코드: \(code))"
        case .serverError(let code):
            return "서버 오류가 발생했습니다. (오류 코드: \(code))"
        case .decodingError(let message):
            return "응답을 처리하지 못했습니다: \(message)"
        case .unknownError:
            return "알 수 없는 오류가 발생했습니다."
        case .typeError:
            return "타입에러"
        }
    }
}
