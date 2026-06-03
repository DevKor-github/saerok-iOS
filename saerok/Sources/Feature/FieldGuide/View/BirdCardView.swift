//
//  BirdCardView.swift
//  saerok
//
//  Created by HanSeung on 4/10/25.
//

import SwiftUI

struct BirdCardView: View {
    let bird: Local.Bird
    let bookmarkTapped: (Local.Bird) async throws -> Void
    @Binding var showPopup: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                if let url = bird.imageURL {
                    AsyncImage(
                        url: url,
                        size: Const.imageSize,
                        scale: .small,
                        downsampling: true,
                        useDiskCache: true
                    )
                    .clipped()
                }
                Color.srWhite
            }

            VStack(spacing: 0) {
                Spacer()
                nameSection
            }
            bookmarkButton
        }
        .frame(height: Const.cardHeight)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 0)
        .contentShape(Rectangle())
    }
}

// MARK: - UI Components
private extension BirdCardView {
    var nameSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            Text(bird.name)
                .font(.SRFontSet.body3)
                .foregroundStyle(.black)

            Text(bird.scientificName)
                .lineLimit(1)
                .font(.SRFontSet.caption1)
                .foregroundStyle(.srGray)
        }
        .padding(.horizontal, Const.nameSectionPaddingH)
        .padding(.vertical, Const.nameSectionPaddingV)
        .padding(.bottom, 8)
        .frame(height: Const.nameSectionHeight)
        .frame(maxWidth: .infinity, alignment: .bottomLeading)
        .background(nameGradientBackground)
    }

    var nameGradientBackground: some View {
        VStack(spacing: 0) {
            Rectangle()
                .frame(height: Const.gradientHeight)
                .foregroundColor(.clear)
                .background(
                    LinearGradient(
                        stops: [
                            .init(color: Color.white.opacity(0.8), location: 0),
                            .init(color: .white, location: 1)
                        ],
                        startPoint: .top,
                        endPoint: UnitPoint(x: 0.5, y: 0.96)
                    )
                )
            
            Color.srWhite
        }
    }
    
    var bookmarkButton: some View {
        Button {
            Task {
                do {
                    HapticManager.shared.trigger(.light)
                    try await bookmarkTapped(bird)
                    HapticManager.shared.trigger(.success)
                }  catch {
                    HapticManager.shared.trigger(.error)
                    showPopup.toggle()
                }
            }
        } label: {
            (bird.isBookmarked ? Image.SRIconSet.scrapFilled : Image.SRIconSet.scrap)
                .frame(.custom(Const.bookmarkButtonSize))
                .padding(.top, Const.bookmarkPaddingTop)
                .padding(.trailing, Const.bookmarkPaddingTrailing)
        }
    }
}

// MARK: - Constants
private extension BirdCardView {
    enum Const {
        static let imageSize = CGSize(width: 184, height: 189)
        static let gradientHeight: CGFloat = 18
        static let cardHeight: CGFloat = 221
        static let nameSectionHeight: CGFloat = 50
        static let nameSectionPaddingH: CGFloat = 13
        static let nameSectionPaddingV: CGFloat = 10
        static let bookmarkButtonSize: CGSize = .init(width: 28, height: 28)
        static let bookmarkPaddingTop: CGFloat = 8
        static let bookmarkPaddingTrailing: CGFloat = 8
    }
}
