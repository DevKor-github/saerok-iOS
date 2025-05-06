//
//  BirdDetailView.swift
//  saerok
//
//  Created by HanSeung on 4/12/25.
//


import Combine
import SwiftUI

struct BirdDetailView: View {
    private let bird: Local.Bird
    
    @Binding var path: NavigationPath
        
    init(_ bird: Local.Bird, path: Binding<NavigationPath>) {
        self.bird = bird
        self._path = path
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            navigationBar
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 30) {
                    birdImageWithTag
                    Group {
                        classification
                        description
                    }
                    .padding(.horizontal, SRDesignConstant.defaultPadding)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .regainSwipeBack()
    }
    
    private var birdImageWithTag: some View {
        VStack(alignment: .leading, spacing: 13) {
            if let url = bird.imageURL {
                ReactiveAsyncImage(url: url, scale: .large, quality: 1, downsampling: false)
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(10)
                    .padding(.horizontal, SRDesignConstant.defaultPadding)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 5) {
                    Color.clear.frame(width: 20)
                    ChipList(icon: .seasonWhite, list: bird.seasons)
                    ChipList(icon: .habitatWhite, list: bird.habitats)
                    ChipList(icon: .sizeWhite, list: [bird.size])
                    Color.clear.frame(width: 20)
                }
            }
        }
    }
    
    private var classification: some View {
        VStack(alignment: .leading, spacing: 13) {
            Text("분류")
                .font(.SRFontSet.subtitle2)
                .bold()
            Text(bird.classification)
                .font(.SRFontSet.caption1)
                .foregroundStyle(.secondary)
                .lineSpacing(5)
        }
    }
    
    private var description: some View {
        VStack(alignment: .leading, spacing: 13) {
            Text("상세 설명")
                .font(.SRFontSet.subtitle2)
                .bold()
            Text(bird.detail)
                .font(.SRFontSet.body2)
                .lineSpacing(5)
            Color.clear
                .frame(height: 80)
        }
    }
    
    
    
    private var navigationBar: some View {
        NavigationBar(
            leading: {
                HStack(spacing: 16) {
                    Button {
                        path.removeLast()
                    } label: {
                        Image.SRIconSet.chevronLeft
                            .frame(.defaultIconSize)
                    }
                    .buttonStyle(.plain)
                    
                    VStack(alignment: .leading) {
                        Text(bird.name)
                            .font(.SRFontSet.subtitle1)
                        Text(bird.scientificName)
                            .font(.SRFontSet.caption1)
                            .foregroundStyle(.gray)
                    }
                }
            },
            trailing: {
                HStack(spacing: 10) {
                    Button { } label: {
                        Image.SRIconSet.penFill.frame(.defaultIconSizeLarge)
                            .padding(.top, 1)
                    }
                    Button {
                        bird.isBookmarked.toggle()
                    } label: {
                        Group {
                            (bird.isBookmarked
                             ? Image.SRIconSet.bookmarkFilled.frame(.defaultIconSize)
                             : Image.SRIconSet.bookmark.frame(.defaultIconSize))
                        }
                        .foregroundStyle(bird.isBookmarked ? Color.main : Color.black)
                    }
                }
                .buttonStyle(.plain)
            }
        )
    }
    
    struct ChipList<T: Hashable & RawRepresentable & CaseIterable>: View where T.RawValue == String {
        
        let icon: Image.SRIconSet
        let list: [T]
        var body: some View {
            HStack {
                icon.frame(.defaultIconSizeSmall)

                if list.isEmpty {
                    Text("미등록")
                } else {
                    Text(list.map(\.rawValue).joined(separator: " • "))
                }
            }
            .font(.SRFontSet.body1)
            .bold()
            .padding(.horizontal, 13)
            .padding(.vertical, 7)
            .foregroundStyle(.srWhite)
            .background(Color.main)
            .cornerRadius(.infinity)
        }
    }
}

#Preview {
    @Previewable @State var path: NavigationPath = .init()
    
    BirdDetailView(.mockData[0], path: $path)
}
