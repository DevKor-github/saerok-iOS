//
//  CollectionLikeCell.swift
//  saerok
//
//  Created by HanSeung on 9/14/25.
//


import SwiftUI

struct CollectionLikerCell: View {
    let item: Local.UserSummary

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ReactiveAsyncImage(
                url: item.profileImageUrl,
                scale: .small,
                size: .init(width: 49, height: 49),
                downsampling: true,
                isCachingEnabled: true
            )
            .frame(width: 49, height: 49)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .inset(by: 0.8)
                    .stroke(.srLightGray, lineWidth: 2)
                )

            Text(item.nickname)
                .font(.SRFontSet.body4_3)
            
            Spacer()
            
            Image.SRIconSet.chevronRight
                .frame(.defaultIconSize)
                .foregroundStyle(.srGray)
        }
        .frame(height: 61)
        .padding(.leading, 7)
        .padding(.trailing, 11)
        .background(Color.srWhite)
        .cornerRadius(20)
        .padding(.horizontal, SRDesignConstant.defaultPadding)
    }
}
