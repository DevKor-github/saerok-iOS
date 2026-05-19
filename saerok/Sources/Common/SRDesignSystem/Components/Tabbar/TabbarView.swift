//
//  TabbarView.swift
//  saerok
//
//  Created by HanSeung on 4/1/25.
//

import SwiftUI

struct TabbarView: View {
    var selectedTab: TabbedItems
    let onTabSelected: (TabbedItems) -> Void
    let onScrollToTop: (TabbedItems) -> Void

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
            ForEach((TabbedItems.allCases), id: \.self) { item in
                Button {
                    let selectedBefore = self.selectedTab
                    onTabSelected(item)
                    HapticManager.shared.trigger(.light)
                    if selectedBefore == item {
                        onScrollToTop(item)
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
