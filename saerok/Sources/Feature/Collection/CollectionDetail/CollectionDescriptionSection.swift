//
//  CollectionDescriptionSection.swift
//  saerok
//
//  Created by HanSeung on 7/17/25.
//


import SwiftUI

struct CollectionDescriptionSection: View {
    let collection: Local.CollectionDetail
    let isFromMapView: Bool
    var path: Binding<NavigationPath>?

    var onLikeToggle: () -> Void
    var onCommentTap: () -> Void
    var onReportTap: () -> Void
    
    // MARK: - Environment
    
    @Environment(\.injected) private var injected: DIContainer
    
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
                .background(Color.lightGray)
            
            HStack(spacing: 0) {
                noteButton(
                    image: (collection.isLiked ? Image.SRIconSet.heartFilled : .heart),
                    index: collection.likeCount,
                    onTap: onLikeToggle,
                )
                
                Divider()
                    .hidden()
                    .frame(width: 1)
                    .background(Color.lightGray)
                
                noteButton(
                    image: .comment,
                    index: collection.commentCount,
                    onTap: onCommentTap
                )
            }
        }
        .background(Color.srWhite)
        .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
    }
    
    func noteButton(image: Image.SRIconSet, index: Int, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            HStack {
                image
                    .frame(.defaultIconSizeLarge)
                    .padding(8)
                Spacer()
                Text("\(index)")
            }
            .frame(width: 146, height: 40)
            .padding(.leading, 5.5)
            .padding(.trailing, 20)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
    
    var infoView: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 5) {
                Image.SRIconSet.pin
                    .frame(.defaultIconSize, tintColor: .pointtext)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(collection.locationAlias)
                        .font(.SRFontSet.body4)
                    Text(collection.address)
                        .font(.SRFontSet.caption3)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    if let path = path {
                        path.wrappedValue = .init()
                    }
                    injected.appState[\.routing.contentView.tabSelection] = .map
                    injected.appState[\.routing.mapView.navigation] = .init(
                        latitude: collection.coordinate.latitude,
                        longitude: collection.coordinate.longitude
                    )
                }) {
                    Image.SRIconSet.chevronRight
                        .frame(.defaultIconSize, tintColor: .srGray)
                }
            }
            
            HStack(spacing: 5) {
                Image.SRIconSet.clock
                    .frame(.defaultIconSize, tintColor: .pointtext)
                
                Text(collection.discoveredDate.korString)
                    .font(.SRFontSet.body4)
            }
            
            HStack(spacing: 5) {
                Image.SRIconSet.myFilled
                    .frame(.defaultIconSize, tintColor: .pointtext)
                
                Text(collection.userNickname)
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
            if let bindingPath = path {
                NavigationLink {
                    BirdDetailView(birdID: birdID, path: bindingPath)
                } label: {
                    Image.SRIconSet.toDogam.frame(.defaultIconSizeVeryLarge)
                }
            } else {
                Button {
                    injected.appState[\.routing.contentView.tabSelection] = .fieldGuide
                    injected.appState[\.routing.fieldGuideView.birdName] = collection.birdName
                } label: {
                    Image.SRIconSet.toDogam.frame(.defaultIconSizeLarge)
                }
            }
        }
    }
    
    @ViewBuilder
    var additionalButton: some View {
        if !isFromMapView {
            Button {
                if let paths = path {
                    paths.wrappedValue.append(CollectionDetailView.Route.edit)
                }
            } label: {
                Image.SRIconSet.edit.frame(.defaultIconSizeLarge)
            }
            .srStyled(.iconButton)
        } else {
            Menu {
                Button(action: onReportTap) {
                    Label("신고하기", systemImage: "light.beacon.max")
                }
            } label: {
                Image.SRIconSet.option.frame(.defaultIconSizeLarge)
            }
            .srStyled(.iconButton)
        }
    }
}

