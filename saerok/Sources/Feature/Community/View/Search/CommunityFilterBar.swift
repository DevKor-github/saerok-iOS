//
//  CommunityFilterBar.swift
//  saerok
//
//  Created by HanSeung on 9/24/25.
//

import SwiftUI

enum CommunitySearchCase: CaseIterable {
    case all
    case collection
    case user
    
    var title: String {
        switch self {
        case .all: "전체"
        case .collection: "새록"
        case .user: "사용자"
        }
    }
}

struct CommunityFilterBar: View {
    @Binding var selected: CommunitySearchCase
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(CommunitySearchCase.allCases, id: \.self) { searchCase in
                let isSelected = selected == searchCase
                
                Button {
                    HapticManager.shared.trigger(.light)
                    selected = searchCase
                } label: {
                    Text(searchCase.title)
                        .font(isSelected ? .SRFontSet.button2 : .SRFontSet.body2)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 15)
                        .background(isSelected ? .pointtext : .srWhite)
                        .foregroundColor(isSelected ? .srWhite : .black)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .inset(by: 0.17)
                                .stroke(.whiteGray, lineWidth: isSelected ? 0 : 0.35)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 15)
    }
}
