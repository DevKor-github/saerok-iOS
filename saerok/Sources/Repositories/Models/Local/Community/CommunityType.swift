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
    case board
    case search(_ text: String)
    
    var title: String {
        switch self {
        case .recent: return "최근에 올라온 새록"
        case .popular: return "요즘 인기있는 새록"
        case .suggestion: return "이 새 이름이 뭔가요?"
        case .board: return "도란도란"
        default: return ""
        }
    }
}

extension CommunityType: Equatable {
    static func == (lhs: CommunityType, rhs: CommunityType) -> Bool {
        switch (lhs, rhs) {
        case (.recent, .recent),
             (.popular, .popular),
             (.suggestion, .suggestion),
             (.board, .board):
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
    /// 전체보기 목록 화면에서 상세로 진입할 때 기록할 Amplitude entry_source.
    /// 둥지 메인(home_feed)과 구분해 어느 목록에서 들어왔는지 식별한다.
    var entrySource: EntrySource {
        switch self {
        case .popular: return .popular
        case .recent: return .recent
        case .suggestion: return .suggestion
        case .board, .search: return .communityFeed
        }
    }

    /// 전체보기 목록(CommunityDetailView)에서 상세 진입 시 기록할 screen.
    /// 한 뷰가 목록 종류로 분기되므로 분기 대상을 접미사로 구분한다.
    var detailScreen: Screen {
        switch self {
        case .popular: return .communityDetailPopular
        case .recent: return .communityDetailRecent
        case .suggestion: return .communityDetailSuggestion
        case .board, .search: return .unknown
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
