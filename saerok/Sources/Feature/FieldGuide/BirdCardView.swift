//
//  BirdCardView.swift
//  saerok
//
//  Created by HanSeung on 4/10/25.
//


import SwiftUI

struct BirdCardView: View {
    private let bird: Local.Bird
    
    init(_ bird: Local.Bird) {
        self.bird = bird
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let url = bird.imageURL {
                AsyncImage(
                    url: url,
                    size: CGSize(width: 120, height: 142),
                    scale: .medium,
                    quality: 0.8,
                    downsampling: true
                )
            }

            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    nameSection
                    Spacer()
                    bookmarkButton
                }
            }
            .frame(alignment: .leading)
            .padding(11)
            .background(.srWhite)
        }
        .frame(height: 198)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle.init(cornerRadius: SRDesignConstant.cardCornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: SRDesignConstant.cardCornerRadius)
                .stroke(Color.border, lineWidth: 1)
        }
    }
}

// MARK: - UI Components

private extension BirdCardView {
    var nameSection: some View {
        VStack(alignment: .leading) {
            Text(bird.name)
                .font(.SRFontSet.h3)
            Text(bird.scientificName)
                .font(.SRFontSet.h4)
                .foregroundStyle(.secondary)
        }
    }
    
    var bookmarkButton: some View {
        Button {
            bird.isBookmarked.toggle()
        } label: {
            Image(bird.isBookmarked ? .bookmarkFill : .bookmark)
                .font(.system(size: 24, weight: bird.isBookmarked ? .regular : .light))
                .foregroundStyle(bird.isBookmarked ? .main : .gray)
        }
    }
}

#Preview {
    BirdCardView(Local.Bird.mockData[0])
        .frame(width: 170)
}
