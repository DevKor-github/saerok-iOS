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
                    ForEach(bird.seasons, id: \.rawValue) { season in
                        chip(season.rawValue)
                    }
                    
                    ForEach(bird.habitats, id: \.rawValue) { habitat in
                        chip(habitat.rawValue)
                    }
                    
                    chip(bird.size.rawValue + " 크기")
                    Color.clear.frame(width: 20)
                }
            }
        }
    }
    
    private var classification: some View {
        VStack(alignment: .leading, spacing: 13) {
            Text("분류")
                .font(.SRFontSet.h3)
                .bold()
            Text(bird.classification)
                .font(.SRFontSet.h4)
                .foregroundStyle(.secondary)
                .lineSpacing(5)
        }
    }
    
    private var description: some View {
        VStack(alignment: .leading, spacing: 13) {
            Text("상세 설명")
                .font(.SRFontSet.h3)
                .bold()
            Text(bird.detail)
                .font(.SRFontSet.h4)
                .lineSpacing(5)
        }
    }
    
    private func chip(_ content: String) -> some View {
        return Text(content)
            .font(.SRFontSet.h6)
            .bold()
            .padding(.horizontal, 13)
            .padding(.vertical, 7)
            .foregroundStyle(.srWhite)
            .background(Color.main)
            .cornerRadius(.infinity)
    }
    
    private var navigationBar: some View {
        NavigationBar(
            leading: {
                HStack(spacing: 16) {
                    Button {
                        path.removeLast()
                    } label: {
                        Image(.chevronLeft)
                    }
                    .buttonStyle(.plain)
                    
                    VStack(alignment: .leading) {
                        Text(bird.name)
                            .font(.SRFontSet.h2)
                        Text(bird.scientificName)
                            .font(.SRFontSet.h3)
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
                            bird.isBookmarked
                            ? Image.SRIconSet.bookmarkFill.frame(.defaultIconSize)
                            : Image.SRIconSet.bookmark.frame(.defaultIconSize)
                        }
                        .foregroundStyle(bird.isBookmarked ? Color.main : Color.black)
                    }
                }
                .buttonStyle(.plain)
            }
        )
    }
}

#Preview {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    appDelegate.rootView
}
