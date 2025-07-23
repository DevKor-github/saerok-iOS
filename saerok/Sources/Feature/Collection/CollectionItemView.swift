//
//  CollectionItemView.swift
//  saerok
//
//  Created by HanSeung on 7/23/25.
//


import SwiftUI

struct CollectionItem: View {
    let bird: Local.CollectionSummary
    var tapped: () -> Void
    
    var body: some View {
        Button(action: tapped) {
            VStack(alignment: .leading, spacing: 8) {
                ReactiveAsyncImage(
                    url: bird.imageURL ?? "",
                    scale: .medium,
                    quality: 0.8,
                    downsampling: true
                )
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 15))
                
                Text(bird.birdName ?? "이름 모를 새")
                    .font(.SRFontSet.caption2)
                    .padding(.leading, 8)
            }
            .padding(.horizontal, 5)
            .padding(.top, 5)
            .padding(.bottom, 8)
            .background(Color.srWhite)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 0)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CollectionItem(bird: .mockData[0], tapped: {})
        .padding(100)
}
