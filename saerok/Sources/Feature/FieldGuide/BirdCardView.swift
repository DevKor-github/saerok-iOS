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
                        size: CGSize(width: 120, height: 198),
                        scale: .medium,
                        quality: 0.8,
                        downsampling: true
                    )
                }
                
                    
            }
            VStack {
                Spacer()
                nameSection
            }
            bookmarkButton
        }
        .frame(height: 198)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle.init(cornerRadius: SRDesignConstant.cardCornerRadius))
        .shadow(radius: 3)
    }
}

// MARK: - UI Components

private extension BirdCardView {
    var nameSection: some View {
        VStack(alignment: .leading) {
            Spacer()
            Text(bird.name)
                .font(.SRFontSet.body3)
            Text(bird.scientificName)
                .font(.SRFontSet.caption1)
                .foregroundStyle(.secondary)
        }
        .frame(height: 90)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            LinearGradient(colors: [
                .srWhite,
                .srWhite.opacity(0.9),
                .clear,
                .clear
            ], startPoint: .bottom, endPoint: .top)
        )
    }
    
    var bookmarkButton: some View {
        Button {
            bird.isBookmarked.toggle()
        } label: {
            (bird.isBookmarked
             ? Image.SRIconSet.scrapFilled
             : Image.SRIconSet.scrap)
            .frame(.defaultIconSizeLarge)
            .padding(.trailing, 6)
            .padding(.top, 7)
        }
    }
}

#Preview {
    BirdCardView(Local.Bird.mockData[1])
        .frame(width: 170)
    Color.clear.frame(height:30)
    BirdCardView(Local.Bird.mockData[2])
        .frame(width: 170)
}
