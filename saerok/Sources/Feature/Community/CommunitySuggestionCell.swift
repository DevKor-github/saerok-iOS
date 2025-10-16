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
        VStack(spacing: 0) {
            imageSection
            descriptionSection
            Spacer()
        }
        .frame(width: 107, height: 127)
        .background(.srWhite)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 0)
    }
    
    private var imageSection: some View {
        ReactiveAsyncImage(
            url: item.thumbnailImageUrl ?? "",
            scale: .small,
            size: .init(width: 97, height: 97),
            downsampling: true
        )
        .aspectRatio(contentMode: .fill)
        .clipped()
        .frame(maxWidth: 97, maxHeight: 97)
        .fixedSize()
        .cornerRadius(15, corners: [.topLeft, .topRight])
        .cornerRadius(5, corners: [.bottomLeft, .bottomRight])
        .padding([.horizontal, .top], 5)
        .padding(.bottom, 4)
    }
    
    private var descriptionSection: some View {
        HStack(spacing: 3) {
            Spacer()
            Image.SRIconSet.unknown
                .frame(.custom(width: 15, height: 15), tintColor: .pointtext)
            Text("\(item.suggestionUserCount ?? 0)명 참여")
                .font(.SRFontSet.caption3)
                .foregroundStyle(.srGray)
        }
        .padding(.trailing, 11)
    }
}

#Preview {
    CommunitySuggestionCell(item: .from(dto: .init(collectionId: 0, imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTMG2ABpDRm1U73-xRewqvyFn4d26Af1KeB1A&s", thumbnailImageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTMG2ABpDRm1U73-xRewqvyFn4d26Af1KeB1A&s", discoveredDate: "", latitude: 0, longitude: 0, locationAlias: "", address: nil, note: nil, likeCount: 0, commentCount: 0, isLiked: false, isPopular: false, bird: nil, user: nil, suggestionUserCount: 5)))
}
