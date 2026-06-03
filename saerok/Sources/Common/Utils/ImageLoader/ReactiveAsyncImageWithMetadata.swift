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
    let onLoaded: (() -> Void)?

    init(
        url: String,
        scale: ImageScale = .small,
        downsampling: Bool = true,
        isCachingEnabled: Bool = true,
        onLoaded: (() -> Void)? = nil
    ) {
        self.url = url
        self.scale = scale
        self.downsampling = downsampling
        self.isCachingEnabled = isCachingEnabled
        self.onLoaded = onLoaded
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

            let cellWidth = UIScreen.main.bounds.width / 2 - 24

            // 메타데이터 + 이미지를 한 번의 다운로드로 함께 로드
            if let result = try? await ImageLoader.loadImageWithMetadata(
                from: url,
                cellWidth: cellWidth,
                scale: scale,
                downsampled: downsampling,
                isCachingEnabled: isCachingEnabled
            ) {
                metadata = result.metadata
                uiImage = result.image
            }

            isLoading = false
            if uiImage != nil { onLoaded?() }
        }
    }
}
