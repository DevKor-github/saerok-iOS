//
//  BirdGridView.swift
//  saerok
//
//  Created by HanSeung on 5/15/25.
//


import SwiftUI

struct BirdGridView: View {
    let birds: [Local.Bird]
    let onTap: (Local.Bird) -> Void

    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 15),
                GridItem(.flexible(), spacing: 15)
            ],
            spacing: 15
        ) {
            ForEach(birds) { bird in
                Button {
                    onTap(bird)
                } label: {
                    BirdCardView(bird)
                }
                .buttonStyle(.plain)
            }

            Group {
                Rectangle()
                Rectangle()
            }
            .foregroundStyle(.clear)
            .frame(height: 600)
        }
        .padding(SRDesignConstant.defaultPadding)
        .background(Color.whiteGray)
    }
}
