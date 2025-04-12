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
    
    @Environment(\.injected) var injected
    
    init(_ bird: Local.Bird, path: Binding<NavigationPath>) {
        self.bird = bird
        self._path = path
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            navigationBar
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    birdImageWithTag
                    classification
                    description
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, SRDesignConstant.defaultPadding)
        }
        .onAppear {
            injected.appState[\.routing.contentView.isTabbarHidden] = true
        }
        .regainSwipeBack()
    }
    
    private var birdImageWithTag: some View {
        VStack(alignment: .leading, spacing: 13) {
            Image(.birdPreview)
                .resizable()
                .frame(height: 248)
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 5) {
                    ForEach(bird.seasons, id: \.rawValue) { season in
                        chip(season.rawValue)
                    }
                    
                    ForEach(bird.habitats, id: \.rawValue) { habitat in
                        chip(habitat.rawValue)
                    }
                    
                    chip(bird.size.rawValue)
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
            .padding(.horizontal, 13)
            .padding(.vertical, 7)
            .background(Color.background)
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
                Button {
                    bird.isBookmarked.toggle()
                } label: {
                    Image(bird.isBookmarked ? .bookmarkFill : .bookmark)
                        .foregroundStyle(bird.isBookmarked ? .main : .black)
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
