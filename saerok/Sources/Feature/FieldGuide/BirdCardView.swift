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
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                if let url = bird.imageURL {
                    AsyncImage(
                        url: url,
                        size: Constants.imageSize,
                        scale: .medium,
                        quality: 0.8,
                        downsampling: true
                    )
                    .clipped()
                    .overlay {
                        VStack {
                            Color.clear
                            LinearGradient.birdCardBackground
                                .frame(height: Constants.gradientHeight)
                        }
                    }
                }
                Color.srWhite
            }

            VStack(spacing: 0) {
                Spacer()
                nameSection
            }
            bookmarkButton
        }
        .frame(height: Constants.cardHeight)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: SRDesignConstant.cardCornerRadius))
        .shadow(radius: Constants.shadowRadius)
    }
}

// MARK: - UI Components

private extension BirdCardView {
    var nameSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            Text(bird.name)
                .font(.SRFontSet.body3)

            Text(bird.scientificName)
                .lineLimit(1)
                .font(.SRFontSet.caption1)
                .foregroundStyle(.secondary)
        }
        .frame(height: Constants.nameSectionHeight)
        .frame(maxWidth: .infinity, alignment: .bottomLeading)
        .padding(.horizontal, Constants.nameSectionPaddingH)
        .padding(.vertical, Constants.nameSectionPaddingV)
    }
    
    var bookmarkButton: some View {
        Button {
            bird.isBookmarked.toggle()
        } label: {
            (bird.isBookmarked
             ? Image.SRIconSet.scrapFilled
             : Image.SRIconSet.scrap)
            .frame(.defaultIconSizeLarge)
            .padding(.trailing, Constants.bookmarkPaddingTrailing)
            .padding(.top, Constants.bookmarkPaddingTop)
        }
    }
}

// MARK: - Constants

private extension BirdCardView {
    enum Constants {
        static let imageSize = CGSize(width: 120, height: 170)
        static let gradientHeight: CGFloat = 85
        static let cardHeight: CGFloat = 198
        static let nameSectionHeight: CGFloat = 40
        static let nameSectionPaddingH: CGFloat = 13
        static let nameSectionPaddingV: CGFloat = 11
        static let bookmarkPaddingTop: CGFloat = 7
        static let bookmarkPaddingTrailing: CGFloat = 6
        static let shadowRadius: CGFloat = 3
    }
}
