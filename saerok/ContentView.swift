//
//  ContentView.swift
//  saerok
//
//  Created by HanSeung on 3/18/25.
//

import SwiftUI

struct ContentView: View {
    @State var selectedTab = 2
    
    var body: some View {
        ZStack(alignment: .bottom){
            Group {
                switch selectedTab {
                case 2:
                    VStack{
                        Text("가나다라마바사\nHello World!")
                            .font(.SRFontSet.h1)
                    }
                
                default:
                    Rectangle()
                        .foregroundStyle(.white)
                        .background(.white)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            TabbarView(selectedTab: selectedTab)
        }
        .ignoresSafeArea(.all)
    }
}

#Preview {
    ContentView()
}
