//
//  AsyncImage.swift
//  ImageManager
//
//  Created by HanSeung on 3/24/25.
//

import SwiftUI

struct AsyncImage: View {
    @State private var uiImage: UIImage? = nil
    let url: URL
    let size: CGSize
    let scale: ImageScale
    let quality: CGFloat

    var body: some View {
        Group {
            if let image = uiImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size.width, height: size.height)
                    .clipped()
            } else {
                ProgressView()
                    .frame(width: size.width, height: size.height)
            }
        }
        .task { [scale = self.scale] in
            uiImage = try? await ImageLoader.loadFromURL(
                from: url,
                size: size,
                scale: scale,
                quality: quality,
                downsampled: true
            )
        }
    }
}
