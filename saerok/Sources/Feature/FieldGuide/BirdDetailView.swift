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
                .allowsTightening(true)
                .font(.SRFontSet.body2)
                .lineSpacing(5)
                .allowsTightening(true)
            
            Color.clear
                .frame(height: 80)
        }
    }
    
    
    
    private var navigationBar: some View {
        NavigationBar(
            leading: {
                HStack(spacing: 18) {
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
                HStack(spacing: 25) {
                    Button {
                        bird.isBookmarked.toggle()
                    } label: {
                        Group {
                            (bird.isBookmarked
                             ? Image.SRIconSet.bookmarkFilled.frame(.defaultIconSizeLarge)
                             : Image.SRIconSet.bookmark.frame(.defaultIconSizeLarge))
                        }
                        .foregroundStyle(bird.isBookmarked ? Color.main : Color.black)
                    }
                    
                    Button { } label: {
                        Image.SRIconSet.penFill.frame(.custom(width: 26, height: 26))
                            .padding(.top, 3)
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

extension String {
    /// 한글 자모 사이에 줄바꿈 힌트용 제로폭 스페이스(`\u{200B}`) 삽입
    func allowLineBreaking() -> String {
        return self.map { String($0) }.joined(separator: "\u{200B}")
    }
}

#Preview {
    @Previewable @State var path: NavigationPath = .init()
    
    BirdDetailView(.mockData[0], path: $path)
}
