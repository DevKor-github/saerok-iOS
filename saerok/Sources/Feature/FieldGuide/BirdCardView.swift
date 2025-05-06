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
                        size: CGSize(width: 120, height: 170),
                        scale: .medium,
                        quality: 0.8,
                        downsampling: true
                    )
                    .clipped()
                    .overlay {
                        VStack{
                            Color.clear
                            LinearGradient.birdCardBackground
                                .frame(height: 85)
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
        .frame(height: 198)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle.init(cornerRadius: SRDesignConstant.cardCornerRadius))
        .shadow(radius: 3)
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
        .frame(height: 40)
        .frame(maxWidth: .infinity, alignment: .bottomLeading)
        .padding(.horizontal, 13)
        .padding(.vertical, 11)

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
