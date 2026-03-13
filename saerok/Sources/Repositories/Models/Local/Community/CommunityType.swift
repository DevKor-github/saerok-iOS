//
//  CommunityType.swift
//  saerok
//
//  Created by HanSeung on 10/9/25.
//


enum CommunityType {
    case recent
    case popular
    case suggestion
    #if DEBUG
    case board
    #endif
    case search(_ text: String)
    
    var title: String {
        switch self {
        case .recent: return "최근에 올라온 새록"
        case .popular: return "요즘 인기있는 새록"
        case .suggestion: return "이 새 이름이 뭔가요?"
        #if DEBUG
        case .board: return "자유게시판"
        #endif
        default: return ""
        }
    }
}

extension CommunityType: Equatable {
    static func == (lhs: CommunityType, rhs: CommunityType) -> Bool {
        switch (lhs, rhs) {
        case (.recent, .recent),
             (.popular, .popular),
             (.suggestion, .suggestion):
            return true
        case let (.search(a), .search(b)):
            return a == b
        default:
            return false
        }
    }
}

extension CommunityType: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .search(let text):
            hasher.combine("search_\(text)")
        default:
            hasher.combine(self.title)
        }
    }
}

extension CommunityType {
    var responseType: Decodable.Type {
        switch self {
        case .recent:
            return DTO.CommunityRecentResponse.self
        case .popular:
            return DTO.CommunityPopularResponse.self
        case .suggestion:
            return DTO.CommunityPendingBirdIdResponse.self
        case .board:
            return EmptyResponse.self
        case .search:
            return EmptyResponse.self
        }
    }
}
