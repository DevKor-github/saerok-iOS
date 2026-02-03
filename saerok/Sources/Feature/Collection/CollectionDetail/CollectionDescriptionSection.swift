//
//  CollectionDescriptionSection.swift
//  saerok
//
//  Created by HanSeung on 7/17/25.
//


import SwiftUI

struct CollectionDescriptionSection: View {
    typealias Route = CollectionDetailRoute
    
    enum Action {
        case likeToggle
        case likeCountTap
        case commentTap
        case reportTap
        case suggestTap
        case navigateToFieldGuide
        case navigateToMap
    }
    
    @EnvironmentObject private var coordinator: AppCoordinator
    let collection: Local.CollectionDetail
    let onAction: (Action) -> Void
    
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
            Text(collection.birdName ?? "이름 모를 새")
                .font(.SRFontSet.subtitle1)
                .padding(.vertical, 19)
                .padding(.horizontal, 17)
                .background(Color.srWhite)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 0)
            Spacer()
            ZStack(alignment: .trailing) {
                Image(.saerokTap)
                trailingButtons
                    .padding(11)
            }
        }
    }
    
    var noteView: some View {
        VStack(spacing: 0) {
            Text(collection.note.allowLineBreaking())
                .font(.SRFontSet.body3_2)
                .lineSpacing(5)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(nil)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 19)
                .padding(.horizontal, 26)
                .padding(.top, 19)
            
            Divider()
                .hidden()
                .frame(height: 1)
                .background(.srLightGray)
            
            HStack(spacing: 0) {
                noteButton(
                    image: (collection.isLiked ? Image.SRIconSet.heartFilled : .heart),
                    index: collection.likeCount,
                    onTap: { onAction(.likeToggle) },
                    additionalTap: { onAction(.likeCountTap) }
                )
                
                Divider()
                    .hidden()
                    .frame(width: 1)
                    .background(.srLightGray)
                
                noteButton(
                    image: .comment,
                    index: collection.commentCount,
                    onTap: { onAction(.commentTap) }
                )
            }
        }
        .background(Color.srWhite)
        .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
    }
    
    func noteButton(
        image: Image.SRIconSet,
        index: Int,
        onTap: @escaping () -> Void,
        additionalTap: (() -> Void)? = nil
    ) -> some View {
        HStack {
            image
                .frame(.defaultIconSizeLarge)
                .padding(8)
                .contentShape(Rectangle())
                .onTapGesture(perform: onTap)
            
            Spacer()
            
            Text("\(index)")
                .contentShape(Rectangle())
                .onTapGesture {
                    if let additionalTap = additionalTap {
                        additionalTap()
                    } else {
                        onTap()
                    }
                }
        }
        .frame(width: 146, height: 40)
        .padding(.leading, 5.5)
        .padding(.trailing, 20)
        .padding(.vertical, 8)
    }
    
    var infoView: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 5) {
                Image.SRIconSet.pin
                    .frame(.defaultIconSize, tintColor: .pointtext)
                
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
                            .frame(.defaultIconSize, tintColor: .srGray)
                    }
                }
                .buttonStyle(.plain)
            }
            
            HStack(spacing: 5) {
                Image.SRIconSet.clock
                    .frame(.defaultIconSize, tintColor: .pointtext)
                
                Text(collection.discoveredDate.korString)
                    .font(.SRFontSet.body4)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.srWhite)
        .cornerRadius(20)
    }

    @ViewBuilder
    var trailingButtons: some View {
        HStack(spacing: 9) {
            toDogamButton
                .background(
                    Circle()
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                )
            
            additionalButton
                .background(
                    Circle()
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                )
        }
    }
    
    @ViewBuilder
    var toDogamButton: some View {
        if let birdID = collection.birdID {
            if !coordinator.path.isEmpty {
                Button {
                    coordinator.push(Route.bird(birdID))
                } label: {
                    Image.SRIconSet.toDogam
                        .frame(.defaultIconSizeVeryLarge)
                }
            } else {
                Button { onAction(.navigateToFieldGuide) } label: {
                    Image.SRIconSet.toDogam
                        .frame(.defaultIconSizeVeryLarge)
                }
            }
        } else {
            Button { onAction(.suggestTap) } label: {
                Image.SRIconSet.unknown
                    .frame(.defaultIconSizeLarge, tintColor: .srWhite)
                    .padding(8)
                    .background(Color.pointtext)
                    .clipShape(Circle())
            }
        }
    }
    
    @ViewBuilder
    var additionalButton: some View {
        if collection.isMine {
            Button {
                coordinator.push(Route.edit)
            } label: {
                Image.SRIconSet.edit.frame(.defaultIconSizeLarge)
            }
            .srStyled(.iconButton)
        } else {
            Menu {
                Button { onAction(.reportTap) } label: {
                    Label("신고하기", systemImage: "light.beacon.max")
                }
            } label: {
                Image.SRIconSet.option.frame(.defaultIconSizeLarge)
            }
            .srStyled(.iconButton)
        }
    }
}

