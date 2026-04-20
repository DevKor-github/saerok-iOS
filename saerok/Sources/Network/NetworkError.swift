//
//  NetworkError.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//

import Foundation

enum NetworkError: Error {
    case unknownError
    case unauthorized           // 401
    case forbidden              // 403
    case notFound               // 404
    case rateLimited            // 429
    case clientError(Int)
    case serverError(Int)
    case decodingError(String)
    case typeError
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "인증이 필요합니다. 다시 로그인해 주세요."
        case .forbidden:
            return "접근 권한이 없습니다."
        case .notFound:
            return "요청한 리소스를 찾을 수 없습니다."
        case .rateLimited:
            return "요청이 너무 많습니다. 잠시 후 다시 시도해 주세요."
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
