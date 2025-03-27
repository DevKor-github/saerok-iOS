//
//  ContentView.swift
//  saerok
//
//  Created by HanSeung on 3/18/25.
//

import SwiftUI

struct ContentView: View {
    @State var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottom){
            Group {
                switch selectedTab {
                default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
                
            ZStack{
                HStack{
                    ForEach((TabbedItems.allCases), id: \.self){ item in
                        Button{
                            selectedTab = item.rawValue
                        } label: {
                            TabItemView(
                                imageName: item.iconName,
                                title: item.title,
                                isActive: (selectedTab == item.rawValue)
                            )
                        }
                    }
                }
                .padding(6)
            }
            .frame(height: 70)
            .cornerRadius(35)
            .padding(.horizontal, 26)
        }
    }
}

#Preview {
    ContentView()
}
