//
//  CommunityCell.swift
//  saerok
//
//  Created by HanSeung on 9/23/25.
//


import SwiftUI

enum CommunityType {
    case recent
    case popular
    case suggestion
    
    var title: String {
        switch self {
        case .recent: return "최근에 올라온 새록"
        case .popular: return "요즘 인기있는 새록"
        case .suggestion: return "이 새 이름이 뭔가요?"
        }
    }
}

struct CommunityCell: View {
    typealias Item = Local.CommunityItemSummary
    typealias CellType = CommunityType
        
    let item: Item
    let type: CellType
    
    var body: some View {
        HStack(spacing: 0) {
            infoSection
            imageSection
        }
        .frame(height: 137)
        .background(Color.srWhite)
        .overlay(alignment: .top) {
            divider
        }
        .overlay(alignment: .bottom) {
            divider
                .offset(y: 1)
        }
        .contentShape(Rectangle())
    }
    
    var infoSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            VStack(alignment: .leading, spacing: 0) {
                Text(subTitleText(item: item, type))
                    .font(.SRFontSet.caption3)
                    .foregroundStyle(.srGray)
                    .padding(.bottom, 9)
                Text(item.birdName ?? "이름 모를 새")
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
                    scale: .small,
                    size: .init(width: 25, height: 25),
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
        .padding(.leading, 24)
        .padding(.trailing, 7)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var imageSection: some View {
        VStack(spacing: 0) {
            ReactiveAsyncImage(
                url: item.imageURL ?? "",
                scale: .small,
                size: .init(width: 89, height: 89),
                downsampling: true
            )
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: 89, maxHeight: 89)
            .clipped()
            .cornerRadius(13)
            .padding(.top, 15)
            .padding(.trailing, 15)

            imageCaptionView(item: item, type)
            .frame(height: 20)
            .padding(.vertical, 8)
            .padding(.horizontal, 19)
        }
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
    
    private func subTitleText(item: Item, _ type: CellType) -> String {
        switch type {
        case .popular:
            "\(item.locationAlias)에서"
        case .recent, .suggestion:
            (item.discoveredDate ?? .now).timeAgoText
        }
    }
    
    @ViewBuilder
    private func imageCaptionView(item: Item, _ type: CellType) -> some View {
        switch type {
        case .suggestion:
            HStack(spacing: 4.87) {
                Image(.unknown)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 11.25, height: 13.75)
                    .foregroundStyle(.pointtext)
                Text("\(item.suggestionUserCount ?? 0)명 참여중")
                    .font(.SRFontSet.body4)
                    .foregroundStyle(.srGray)
            }
        default:
            HStack(spacing: 12) {
                iconWithCount(.heartFilled, item.likeCount)
                iconWithCount(.commentFilled, item.commentCount)
            }
        }
    }
    
    private let divider: some View = {
        Rectangle()
            .fill(Color.srLightGray)
            .frame(height: 1)
    }()
}

#Preview {
    CommunityCell(item: .mock1, type: .recent)
    CommunityCell(item: .pendingMock1, type: .suggestion)
}
