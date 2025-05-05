//
//  TabbedItems.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//

import SwiftUI

enum TabbedItems: Int, CaseIterable {
    case community = 0
    case fieldGuide
    case home
    case collection
    case profile
    
    var title: String {
        switch self {
        case .community:
            return "커뮤니티"
        case .fieldGuide:
            return "도감"
        case .home:
            return "지도"
        case .collection:
            return "컬렉션"
        case .profile:
            return "MY"
        }
    }
    
    var icon: Image.SRIconSet {
        switch self {
        case .community:
            return Image.SRIconSet.ellipsisMessage
        case .fieldGuide:
            return Image.SRIconSet.book
        case .home:
            return Image.SRIconSet.house
        case .collection:
            return Image.SRIconSet.heart
        case .profile:
            return Image.SRIconSet.person
        }
    }
}
