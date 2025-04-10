//
//  BirdCard.swift
//  saerok
//
//  Created by HanSeung on 4/10/25.
//

import SwiftUI

struct BirdCard: View {
    let bird: Local.Bird
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(.birdPreview)
                .resizable()
                .frame(height: 142)
                .aspectRatio(contentMode: .fit)
            
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text(bird.name)
                            .font(.SRFontSet.h3)
                        Text(bird.scientificName)
                            .font(.SRFontSet.h4)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button {
                        bird.isBookmarked.toggle()
                    } label: {
                        Image(bird.isBookmarked ? .bookmarkFill : .bookmark)
                            .font(.system(size: 24, weight: bird.isBookmarked ? .regular : .light))
                            .foregroundStyle(bird.isBookmarked ? .main : .gray)
                    }
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
