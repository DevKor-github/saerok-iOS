//
//  NearbyCell.swift
//  saerok
//
//  Created by HanSeung on 8/11/25.
//


import SwiftUI

struct NearbyCell: View {
    let item: Local.NearbyCollectionSummary
    
    var body: some View {
        HStack(spacing: 0) {
            infoSection
            imageSection
        }
        .frame(maxWidth: .infinity)
        .frame(height: 141)
        .background(Color.srWhite)
        .cornerRadius(20)
    }
}

private extension NearbyCell {
    var infoSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            VStack(alignment: .leading, spacing: 0) {
                Text("\(item.locationAlias)에서")
                    .font(.SRFontSet.caption3)
                    .foregroundStyle(.srGray)
                    .padding(.bottom, 9)
                Text(item.koreanName ?? "이름 모를 새")
                    .font(.SRFontSet.body3)
                    .foregroundStyle(.black)
                    .padding(.bottom, 4)
                Text(item.note)
                    .font(.SRFontSet.caption1_2)
                    .foregroundStyle(.srDarkGray)
                    .lineSpacing(4)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            .frame(height: 86)
                        
            HStack(spacing: 5) {
                ReactiveAsyncImage(
                    url: item.user.profileImageUrl,
                    scale: .medium,
                    quality: 0.8,
                    downsampling: true
                )
                .frame(width: 25, height: 25)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .inset(by: 0.8)
                        .stroke(.srLightGray, lineWidth: 2)
                )
                
                Text(item.user.nickname)
                    .font(.SRFontSet.caption1)
            }
            .padding(.bottom, 0)
        }
        .padding(.leading, 15)
        .padding(.trailing, 7)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var imageSection: some View {
        VStack(spacing: 0) {
            ReactiveAsyncImage(
                url: item.imageUrl ?? "",
                scale: .medium,
                quality: 0.8,
                downsampling: true
            )
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: 89, maxHeight: 89)
            .clipped()
            .cornerRadius(13)
            .padding(.top, 15)
            .padding(.trailing, 15)

            
            HStack(spacing: 12) {
                iconWithCount(.heartFilled, item.likeCount)
                iconWithCount(.commentFilled, item.commentCount)
            }
            .frame(height: 20)
            .padding(.vertical, 8)
            .padding(.horizontal, 19)
        }
    }
    
    func iconWithCount(_ image: Image.SRIconSet, _ value: Int) -> some View {
        return HStack(spacing: 3) {
            image
                .frame(.custom(width: 15, height: 15), tintColor: .whiteGray)
            
            Text("\(value)")
                .font(.SRFontSet.body4)
                .foregroundStyle(.srGray)
        }
    }
}
