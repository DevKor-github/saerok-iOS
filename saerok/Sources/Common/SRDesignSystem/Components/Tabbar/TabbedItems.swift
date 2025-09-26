//
//  TabbedItems.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//

import SwiftUI

enum TabbedItems: Int, CaseIterable {
    case collection = 0
    case fieldGuide 
    case map
    case community
    case profile
    
    var title: String {
        switch self {
        case .fieldGuide:
            return "도감"
        case .map:
            return "지도"
        case .collection:
            return "새록"
        case .community:
            return "둥지"
        case .profile:
            return "마이"
        }
    }
    
    var icon: Image.SRIconSet {
        switch self {
        case .fieldGuide:
            return Image.SRIconSet.dogam
        case .map:
            return Image.SRIconSet.home
        case .collection:
            return Image.SRIconSet.saerok
        case .community:
            return Image.SRIconSet.doongzi
        case .profile:
            return Image.SRIconSet.my
        }
    }
    
    var iconSelected: Image.SRIconSet {
        switch self {
        case .fieldGuide:
            return Image.SRIconSet.dogamFilled
        case .map:
            return Image.SRIconSet.homeFilled
        case .collection:
            return Image.SRIconSet.saerokFilled
        case .community:
            return Image.SRIconSet.doongziFilled
        case .profile:
            return Image.SRIconSet.myFilled
        }
    }
}
