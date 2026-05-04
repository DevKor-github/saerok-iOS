//
//  CommunityUserCell.swift
//  saerok
//
//  Created by HanSeung on 9/24/25.
//


import SwiftUI

struct CommunityUserCell: View {
    let item: Local.UserSummary
    let keyword: String

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ReactiveAsyncImage(
                url: item.profileImageUrl,
                scale: .small,
                size: .init(width: 49, height: 49),
                downsampling: true
            )
            .frame(width: 49, height: 49)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .inset(by: 0.8)
                    .stroke(.srLightGray, lineWidth: 2)
                )

            Text(item.nickname.highlighted(keyword: keyword))
                .font(.SRFontSet.body4_3)
            
            Spacer()
            
            Image.SRIconSet.chevronRight
                .frame(.default)
                .foregroundStyle(.srGray)
        }
        .padding(.vertical, 11)
        .padding(.horizontal, 24)
        .background(Color.srWhite)
        .overlay(alignment: .top) {
            divider
        }
        .overlay(alignment: .bottom) {
            divider
                .offset(y: 1)
        }
    }
    
    private let divider: some View = {
        Rectangle()
            .fill(Color.srLightGray)
            .frame(height: 1)
    }()
}
