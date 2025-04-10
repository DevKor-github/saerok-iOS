//
//  BirdCard.swift
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
            Image(.birdPreview)
                .resizable()
                .frame(height: 142)
                .aspectRatio(contentMode: .fit)
            
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
