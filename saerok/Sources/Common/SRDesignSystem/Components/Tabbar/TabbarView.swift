//
//  TabbarView.swift
//  saerok
//
//  Created by HanSeung on 4/1/25.
//

import SwiftUI

struct TabbarView: View {
    @State var selectedTab: Int
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.black.opacity(0.15), Color.clear]),
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: 100)
                .offset(y: -30)
                
                HStack {
                    ForEach((TabbedItems.allCases), id: \.self){ item in
                        Button{
                            selectedTab = item.rawValue
                        } label: {
                            HStack {
                                Spacer()
                                TabItemView(
                                    icon: item.icon,
                                    title: item.title,
                                    isActive: (selectedTab == item.rawValue)
                                )
                                Spacer()
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 68, alignment: .top)
                .padding(.horizontal, 16)
                .background(Color.background)
                .cornerRadius(18)
            }
        }
    }
}
