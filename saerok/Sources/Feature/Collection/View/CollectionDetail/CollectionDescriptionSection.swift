//
//  CollectionDescriptionSection.swift
//  saerok
//
//  Created by HanSeung on 7/17/25.
//

import SwiftUI

//develop
struct CollectionDescriptionSection: View {
    typealias Route = CollectionDetailRoute
    //사용자 차단
    @AppStorage("blockable") var isBlockable: Bool = false

    enum Action {
        case reportTap
        case suggestTap
        case navigateToFieldGuide
        case navigateToOther(_ userId: Int)
        case navigateToMap
        //사용자 차단
        case blockUserTap
    }
    
    @EnvironmentObject private var coordinator: AppCoordinator
    let collection: Local.CollectionDetail
    let onAction: (Action) -> Void
    private var isUnknownBird: Bool { collection.birdID == nil }

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 10) {
                noteView
                infoView
            }
            .padding(.top, 41)
            
            nameView
        }
    }
}

private extension CollectionDescriptionSection {
    var nameView: some View {
        HStack {
            nameTag
            Spacer()
            saerokTab
        }
    }
    
    var nameTag: some View {
        return HStack(spacing: 6.5) {
            Text(collection.birdName ?? "이름 모를 새")
                .font(.SRFontSet.subtitle1)
                .foregroundStyle(isUnknownBird ? Color.srGray : .primary)
                .padding(.trailing, isUnknownBird ? 3.5 : 0)
            if !isUnknownBird {
                Image.SRIconSet.chevronRight
                    .frame(.default, tintColor: .srGray)
                    .padding(.bottom, 1)
            }
        }
        .padding(.vertical, 19)
        .padding(.leading, 17)
        .padding(.trailing, 13.5)
        .background(Color.srWhite)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 0)
        .onTapGesture {
            if !isUnknownBird {
                if coordinator.path.isEmpty {
                    onAction(.navigateToFieldGuide)
                } else {
                    coordinator.push(Route.bird(collection.birdID!))
                }
            }
        }
    }
    
    var saerokTab: some View {
        return ZStack(alignment: .trailing) {
            isUnknownBird ? Image(.saerokTapLarge) : Image(.saerokTapSmall)
            trailingButtons
                .padding([.top, .horizontal], 11)
                .padding(.bottom, 9)
        }
    }
    
    @ViewBuilder
    var trailingButtons: some View {
        HStack(spacing: 9) {
            if isUnknownBird {
                suggestButton
                    .background(
                        Circle()
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    )
            }
            
            additionalButton
                .background(
                    Circle()
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                )
        }
    }
    
    var noteView: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 7) {
                Text(collection.note.allowLineBreaking())
                    .font(.SRFontSet.body3_2)
                    .lineSpacing(5)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(collection.uploadDate.timeAgoText)
                    .font(.SRFontSet.caption3)
                    .foregroundStyle(.srGray)
            }
            .padding(.vertical, 19)
            .padding(.horizontal, 28)
            .padding(.top, 19)
            
            Divider()
                .hidden()
                .frame(height: 1)
                .background(.srLightGray)
            
            profileView
        }
        .background(Color.srWhite)
        .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
    }
    
    var profileView: some View {
        Button {
            onAction(.navigateToOther(collection.user.id))
        } label: {
            HStack(spacing: 7) {
                ReactiveAsyncImage(
                    url: collection.user.profileImageUrl,
                    scale: .small,
                    size: .init(width: 25, height: 25),
                    downsampling: true
                )
                .frame(width: 25, height: 25)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .inset(by: 0.6)
                        .stroke(.srLightGray, lineWidth: 2)
                )
                .id(collection.id)
                
                Text(collection.user.nickname)
                    .font(.SRFontSet.caption1)
                Spacer()
                Image.SRIconSet.chevronRight
                    .frame(.default, tintColor: .srGray)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    var infoView: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 5) {
                Image.SRIconSet.pin
                    .frame(.default, tintColor: .pointtext)
                
                Button(action: {
                    coordinator.clear()
                    onAction(.navigateToMap)
                }) {
                    HStack(alignment: .top, spacing: 0) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(collection.locationAlias)
                                .font(.SRFontSet.body4)
                            Text(collection.address)
                                .font(.SRFontSet.caption3)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Image.SRIconSet.chevronRight
                            .frame(.default, tintColor: .srGray)
                    }
                }
                .buttonStyle(.plain)
            }
            
            HStack(spacing: 5) {
                Image.SRIconSet.clock
                    .frame(.default, tintColor: .pointtext)
                
                Text("\(collection.discoveredDate.toFullString) 발견")
                    .font(.SRFontSet.body4)
            }
            
            if collection.isMine {
                let isPublic = collection.accessLevel == .publicAccess
                HStack(spacing: 5) {
                    (isPublic ? Image.SRIconSet.unlock : Image.SRIconSet.lockFilled)
                        .frame(.default, tintColor: isPublic ? .pointtext : .srLightGray)
                    
                    Text(isPublic ? "함께 보기" : "나만 보기")
                        .font(.SRFontSet.body4)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.srWhite)
        .cornerRadius(20)
    }
    
    var suggestButton: some View {
        Button { onAction(.suggestTap) } label: {
            Image.SRIconSet.unknown
                .frame(.large, tintColor: .srWhite)
                .padding(8)
                .background(Color.pointtext)
                .clipShape(Circle())
        }
    }
    
    @ViewBuilder
    var additionalButton: some View {
        if collection.isMine {
            Button {
                coordinator.push(Route.edit)
            } label: {
                Image.SRIconSet.edit.frame(.large)
            }
            .srStyled(.iconButton)
        } else {
            Menu {
                Button { onAction(.reportTap) } label: {
                    Label("신고하기", systemImage: "light.beacon.max")
                }
                
                //사용자 차단
                if isBlockable {
                    Button { onAction(.blockUserTap) } label: {
                        Label("사용자 차단하기", systemImage: "person.fill.xmark")
                    }
                }
            } label: {
                Image.SRIconSet.option.frame(.large)
            }
            .srStyled(.iconButton)
        }
    }
}
