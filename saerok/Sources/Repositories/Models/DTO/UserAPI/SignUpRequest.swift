//
//  SignUpRequest.swift
//  saerok
//
//  Created by HanSeung on 3/9/26.
//

extension DTO {
    struct SignUpRequest: Encodable {
        let nickname: String
        let signupSource: SignUpSource
    }
}

enum SignUpSource: String, Encodable, CaseIterable {
    case instagram = "INSTAGRAM"
    case other_sns = "OTHER_SNS"
    case friend = "FRIEND"
    case community = "COMMUNITY"
    case etc = "ETC"
    
    var title: String {
        switch self {
        case .instagram: "인스타그램"
        case .other_sns: "그 외 SNS\n(X, 블로그 등)"
        case .friend: "지인 추천, 홍보물"
        case .community: "탐조 관련 커뮤니티\n(카페, 오픈채팅 등)"
        case .etc: "기타 (그 외)"
        }
    }
}
