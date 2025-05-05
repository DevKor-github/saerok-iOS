//
//  BirdCollectionCardView.swift
//  saerok
//
//  Created by HanSeung on 4/10/25.
//


import SwiftUI

struct BirdCollectionCardView: View {
    private let bird: Local.CollectionBird
    
    init(_ bird: Local.CollectionBird) {
        self.bird = bird
    }
    
    var body: some View {
        HStack(spacing: 0) {
            if let url = bird.imageURL.first {
                ReactiveAsyncImage(
                    url: url,
                    scale: .medium,
                    quality: 0.8,
                    downsampling: true
                )
                .frame(width: Constants.cardHeight)
            } else if let imageData = bird.imageData.first {
                Image(uiImage: UIImage(data: imageData) ?? .birdPreview)
                    .resizable()
                    .frame(width: Constants.cardHeight)
                    .clipShape(Rectangle())
            }
            
            VStack(alignment: .leading) {
                nameSection
                Spacer()
                detailSection
            }
            .padding(11)

            Spacer()
        }
        .background(.srWhite)
        .frame(height: 123)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle.init(cornerRadius: SRDesignConstant.cardCornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: SRDesignConstant.cardCornerRadius)
                .stroke(Color.border, lineWidth: 1)
        }
    }
}

// MARK: - UI Components

private extension BirdCollectionCardView {
    var nameSection: some View {
        VStack(alignment: .leading) {
            Text(bird.bird?.name ?? bird.customName ?? "")
                .font(.SRFontSet.h3)
            Text(bird.bird?.scientificName ?? "")
                .font(.SRFontSet.h4)
                .foregroundStyle(.secondary)
        }
    }
    
    var detailSection: some View {
        VStack(alignment: .leading) {
            Text(bird.date.toFullString)
            Text(bird.locationDescription ?? "")
        }
        .font(.SRFontSet.h4)
        .foregroundStyle(.primary)
    }
}

// MARK: - Constants

private extension BirdCollectionCardView {
    enum Constants {
        static let cardHeight: CGFloat = 143
    }
}

#Preview {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    appDelegate.rootView
}
