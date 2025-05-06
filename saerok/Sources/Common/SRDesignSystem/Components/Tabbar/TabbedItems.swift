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
            return "둥지"
        case .fieldGuide:
            return "도감"
        case .home:
            return "지도"
        case .collection:
            return "새록"
        case .profile:
            return "MY"
        }
    }
    
    var icon: Image.SRIconSet {
        switch self {
        case .community:
            return Image.SRIconSet.doongzi
        case .fieldGuide:
            return Image.SRIconSet.dogam
        case .home:
            return Image.SRIconSet.home
        case .collection:
            return Image.SRIconSet.heart
        case .profile:
            return Image.SRIconSet.my
        }
    }
    
    var iconSelected: Image.SRIconSet {
        switch self {
        case .community:
            return Image.SRIconSet.doongziFilled
        case .fieldGuide:
            return Image.SRIconSet.dogamFilled
        case .home:
            return Image.SRIconSet.homeFilled
        case .collection:
            return Image.SRIconSet.heartFilled
        case .profile:
            return Image.SRIconSet.myFilled
        }
    }
}
