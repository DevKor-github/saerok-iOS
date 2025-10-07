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
            VStack(alignment: .leading, spacing: 5.5) {
                nameTag(item: item, type)
                Text(item.note)
                    .font(.SRFontSet.body3)
                    .foregroundStyle(.black)
                HStack(spacing: 7) {
                    Text(item.discoveredDate?.timeAgoText ?? "방금 전")
                    comma
                    Text("\(item.locationAlias)에서")
                }
                .foregroundStyle(.srGray)
                .font(.SRFontSet.caption3)
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
        VStack(alignment: .trailing, spacing: 0) {
            ZStack(alignment: .bottomLeading) {
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
                .padding(.top, showCaption ? 12 : 0)
                .padding(.trailing, 24)
                
                if item.isPopular && type != .popular {
                    popularBadge
                        .offset(x: 74, y: 4)
                }
            }
            
            imageCaptionView
                .frame(height: 20)
                .padding(.vertical, 8)
                .padding(.horizontal, 24)
        }
    }
    
    private func nameTag(item: Item, _ type: CellType) -> some View {
        Text(item.birdName ?? (type == .suggestion ? "이름 모를 새" : "이름을 알려주세요!"))
            .font(.SRFontSet.caption3_2)
            .padding(.horizontal, 3)
            .padding(.vertical, 1)
            .foregroundStyle(tagTextColor(item: item, type: type))
            .background(tagBackgroundColor(item: item, type: type))
            .cornerRadius(5)
    }
    
    private func tagTextColor(item: Item, type: CellType) -> Color {
        switch type {
        case .suggestion:
            return .srGray
        default:
            return item.birdName == nil ? .srWhite : .srGray
        }
    }
    
    private func tagBackgroundColor(item: Item, type: CellType) -> Color {
        switch type {
        case .suggestion:
            return .srLightGray
        default:
            return item.birdName == nil ? .pointtext : .srLightGray
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
    
    @ViewBuilder
    private var imageCaptionView: some View {
        if showCaption {
            HStack(spacing: 12) {
                if item.likeCount > 0 {
                    iconWithCount(.heartFilled, item.likeCount)
                }
                if item.commentCount > 0 {
                    iconWithCount(.commentFilled, item.commentCount)
                }
                if let count = item.suggestionUserCount,
                   count > 0
                {
                    iconWithCount(.unknown, count)
                }
            }
        }
    }
    
    private var showCaption: Bool {
        item.likeCount > 0 ||
        item.commentCount > 0 ||
        (item.suggestionUserCount ?? 0) > 0
    }
    
    private let divider: some View = {
        Rectangle()
            .fill(Color.srLightGray)
            .frame(height: 1)
    }()
    
    private let comma: some View = {
        Rectangle()
            .foregroundColor(.clear)
            .frame(width: 2, height: 2)
            .background(Color(red: 0.59, green: 0.59, blue: 0.59))
            .cornerRadius(1)
    }()
    
    private let popularBadge: some View = {
        Image.SRIconSet.fire
            .frame(.defaultIconSize, tintColor: .srWhite)
            .padding(4)
            .background(Circle().fill(Color.fire))
    }()
}
