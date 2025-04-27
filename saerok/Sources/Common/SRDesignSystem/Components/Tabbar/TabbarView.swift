//
//  TabbarView.swift
//  saerok
//
//  Created by HanSeung on 4/1/25.
//

import SwiftUI

struct TabbarView: View {
    var selectedTab: TabbedItems
    @Environment(\.injected) var injected

    var body: some View {
        VStack {
            Spacer()
            ZStack {
                shadow
                tabItems
            }
        }
    }
    
    // MARK: - UI Components

    private let shadow: some View = {
        LinearGradient(
            gradient: Gradient(colors: [Color.white, Color.clear]),
            startPoint: .bottom,
            endPoint: .top
        )
        .frame(height: 94)
        .offset(y: -30)
        .allowsHitTesting(false)
    }()
    
    private var tabItems: some View {
        HStack {
            ForEach((TabbedItems.allCases), id: \.self){ item in
                Button {
                    injected.appState[\.routing.contentView.tabSelection] = item
                } label: {
                    HStack {
                        Spacer()
                        TabItemView(
                            icon: item.icon,
                            title: item.title,
                            isActive: (selectedTab == item)
                        )
                        Spacer()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 94, alignment: .top)
        .padding(.horizontal, 16)
        .background(Color.white)
        .cornerRadius(18)
    }
}
