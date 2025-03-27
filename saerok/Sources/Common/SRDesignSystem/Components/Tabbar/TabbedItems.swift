//
//  TabbedItems.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//

enum TabbedItems: Int, CaseIterable {
    case explore = 0
    case message
    case wishList
    case profile
    
    var title: String {
        switch self {
        case .explore:
            return "검색"
        case .message:
            return "메시지"
        case .wishList:
            return "위시리스트"
        case .profile:
            return "프로필"
        }
    }
    
    var iconName: String {
        switch self {
        case .explore:
            return "magnifyingglass"
        case .message:
            return "bubble"
        case .wishList:
            return "heart"
        case .profile:
            return "person.circle"
        }
    }
}
