//
//  BirdCardView.swift
//  saerok
//
//  Created by HanSeung on 4/10/25.
//


import SwiftUI

struct BirdCardView: View {
    private let bird: Local.Bird
    @Binding var showPopup: Bool
    
    @Environment(\.injected) var injected
    private var isGuest: Bool { injected.appState[\.authStatus] == .guest }
    
    init(_ bird: Local.Bird, showPopup: Binding<Bool>) {
        self.bird = bird
        self._showPopup = showPopup
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

            Text(bird.scientificName)
                .lineLimit(1)
                .font(.SRFontSet.caption1)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, Constants.nameSectionPaddingH)
        .padding(.vertical, Constants.nameSectionPaddingV)
        .padding(.bottom, 3)
        .frame(height: Constants.nameSectionHeight)
        .frame(maxWidth: .infinity, alignment: .bottomLeading)
        .background(nameGradientBackground)
        .cornerRadius(10)
    }

    var nameGradientBackground: some View {
        VStack(spacing: 0) {
            Rectangle()
                .frame(height: Constants.gradientHeight)
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
                if !isGuest {
                    HapticManager.shared.trigger(.light)
                    self.bird.isBookmarked = try await injected.interactors.fieldGuide.toggleBookmark(birdID: bird.id)
                    HapticManager.shared.trigger(.success)
                } else {
                    HapticManager.shared.trigger(.error)
                    showPopup.toggle()
                }
            }
        } label: {
            (bird.isBookmarked ? Image.SRIconSet.scrapFilled : Image.SRIconSet.scrap)
                .frame(.defaultIconSizeLarge)
                .padding(.top, Constants.bookmarkPaddingTop)
                .padding(.trailing, Constants.bookmarkPaddingTrailing)
        }
    }
}

// MARK: - Constants

private extension BirdCardView {
    enum Constants {
        static let imageSize = CGSize(width: 120, height: 170)
        static let gradientHeight: CGFloat = 23
        static let cardHeight: CGFloat = 198
        static let nameSectionHeight: CGFloat = 52
        static let nameSectionPaddingH: CGFloat = 13
        static let nameSectionPaddingV: CGFloat = 10
        static let bookmarkPaddingTop: CGFloat = 7
        static let bookmarkPaddingTrailing: CGFloat = 6
        static let shadowRadius: CGFloat = 3
    }
}

#Preview {
    @Previewable @State var showPopup = false
    BirdGridView(birds: Local.Bird.mockData, onTap: {_ in }, showPopup: $showPopup)
    .frame(maxWidth: .infinity)
}
