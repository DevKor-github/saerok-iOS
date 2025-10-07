//
//  CommunitySuggestionCell.swift
//  saerok
//
//  Created by HanSeung on 9/23/25.
//


import SwiftUI

struct CommunitySuggestionCell: View {
    typealias Item = Local.CommunityItemSummary
    
    let item: Item
    
    var body: some View {
        HStack(spacing: 0) {
            imageSection
            descriptionSection
            Spacer()
        }
        .frame(width: 225, height: 107)
        .background(.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 0)
    }
    
    private var imageSection: some View {
        ReactiveAsyncImage(
            url: item.imageURL ?? "",
            scale: .small,
            size: .init(width: 97, height: 97),
            downsampling: true
        )
        .aspectRatio(contentMode: .fill)
        .frame(maxWidth: 97, maxHeight: 97)
        .clipped()
        .cornerRadius(15)
        .padding(5)
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 3) {
                Image.SRIconSet.pin
                    .frame(.defaultIconSize, tintColor: .whiteGray)
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.address ?? "")
                        .font(.SRFontSet.body4_3)
                        .lineLimit(1)
                    Text(item.discoveredDate?.timeAgoText ?? "방금 전")
                        .font(.SRFontSet.caption3)
                        .foregroundStyle(.srGray)
                        .lineLimit(1)
                }
            }
            Spacer()
            imageCaptionView
        }
        .padding(.top, 8)
        .padding(.bottom, 5)
    }
    
    private func iconWithCount(_ image: Image.SRIconSet, _ value: Int) -> some View {
        return HStack(spacing: 3) {
            image
                .frame(.custom(width: 15, height: 15), tintColor: .whiteGray)
            
            Text("\(value)")
                .font(.SRFontSet.body4)
                .foregroundStyle(.srGray)
        }
    }
    
    private var imageCaptionView: some View {
        HStack(alignment: .center, spacing: 4.87) {
            Image(.unknown)
                .renderingMode(.template)
                .resizable()
                .frame(width: 11.25, height: 13.75)
                .foregroundStyle(.pointtext)
            Text("\(item.suggestionUserCount ?? 0)명")
                .font(.SRFontSet.body4)
                .foregroundStyle(.srGray)
        }
        .frame(height: 20)
    }
}
