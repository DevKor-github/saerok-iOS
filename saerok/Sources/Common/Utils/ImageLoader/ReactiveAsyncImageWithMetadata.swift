//
//  ReactiveAsyncImageWithMetadata.swift
//  saerok
//
//  Created by HanSeung on 9/26/25.
//


import SwiftUI

struct ReactiveAsyncImageWithMetadata: View {
    @State private var uiImage: UIImage? = nil
    @State private var metadata: ImageMetadata? = nil
    @State private var isLoading: Bool = true
    
    let url: String
    let scale: ImageScale
    let downsampling: Bool
    let isCachingEnabled: Bool
    
    init(
        url: String,
        scale: ImageScale = .small,
        downsampling: Bool = true,
        isCachingEnabled: Bool = true
    ) {
        self.url = url
        self.scale = scale
        self.downsampling = downsampling
        self.isCachingEnabled = isCachingEnabled
    }
    
    var body: some View {
        Group {
            if let image = uiImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if let metadata = metadata {
                Color.border
                    .aspectRatio(metadata.aspectRatio, contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .shimmer(when: $isLoading)
            } else {
                Color.border
                    .shimmer(when: $isLoading)
            }
        }
        .task {
            guard let url = URL(string: url),
                  uiImage == nil
            else { return }
            
            if metadata == nil {
                metadata = try? await ImageLoader.fetchMetadata(from: url)
            }
            
            if let metadata {
                let cellWidth = UIScreen.main.bounds.width / 2 - 24 
                let cellHeight = cellWidth / metadata.aspectRatio
                let targetSize = CGSize(width: cellWidth, height: cellHeight)
                
                uiImage = try? await ImageLoader.loadFromURL(
                    from: url,
                    size: targetSize,
                    scale: scale,
                    downsampled: downsampling,
                    isCachingEnabled: isCachingEnabled
                )
            }
            
            isLoading = false
        }
    }
}
