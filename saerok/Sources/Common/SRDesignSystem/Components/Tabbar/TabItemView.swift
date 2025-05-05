//
//  TabItemView.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//

import SwiftUI

struct TabItemView: View {
    let icon: Image.SRIconSet
    let title: String
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            tabIcon
            titleText
        }
        .frame(width: 51)
        .background(.clear)
    }
}

// MARK: - UI Components

private extension TabItemView {
    var tabIcon: some View {
        icon
            .frame(.defaultIconSize)
            .bold(isActive)
            .foregroundColor(isActive ? .main : .gray)
    }
    
    var titleText: some View {
        Text(title)
            .font(isActive ? .SRFontSet.tabbarSelected : .SRFontSet.tabbar)
            .foregroundColor(isActive ? .main : .gray)
    }
}
