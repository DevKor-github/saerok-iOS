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
            tabItems
                .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 0)
        }
        .padding()
    }
    
    // MARK: - UI Components
    
    private var tabItems: some View {
        HStack {
            ForEach((TabbedItems.allCases), id: \.self){ item in
                Button {
                    injected.appState[\.routing.contentView.tabSelection] = item
                    HapticManager.shared.trigger(.light)
                    if item == .fieldGuide {
                        injected.appState[\.routing.fieldGuideView.scrollToTop] = UUID()
                    }
                } label: {
                    HStack {
                        Spacer()
                        TabItemView(
                            icon: item.icon,
                            iconFilled: item.iconSelected,
                            title: item.title,
                            isActive: (selectedTab == item)
                        )
                        Spacer()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 78)
        .padding(.horizontal, 16)
        .background(Color.white)
        .cornerRadius(.infinity)
    }
}

#Preview {
    ContentView()
}

