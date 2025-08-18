//
//  AsyncImage.swift
//  saerok
//
//  Created by HanSeung on 4/12/25.
//


import SwiftUI

struct AsyncImage: View {
    @State private var uiImage: UIImage? = nil
    @State private var isLoading: Bool = true
    let url: String
    let size: CGSize
    let scale: ImageScale
    let quality: CGFloat
    let downsampling: Bool
    
    var body: some View {
        GeometryReader { geometry in
            content(in: geometry.size.width)
        }
        .frame(height: size.height)
        .task { [scale = self.scale] in
            uiImage = try? await ImageLoader.loadFromURL(
                from: URL(string: url),
                size: size,
                scale: scale,
                quality: quality,
                downsampled: downsampling
            )
            isLoading = false
        }
    }
    
    @ViewBuilder
    private func content(in parentWidth: CGFloat) -> some View {
        if let image = uiImage {
            imageView(for: image, parentWidth: parentWidth)
        } else {
            Color.border
                .frame(height: size.height)
                .frame(maxWidth: .infinity)
                .shimmer(when: $isLoading)
        }
    }
    
    /// 주어진 UIImage를 기반으로 적절한 표시 방법을 결정하여 반환하는 ViewBuilder 함수입니다.
    /// - Parameters:
    ///   - image: 화면에 표시할 `UIImage` 객체입니다.
    ///   - parentWidth: 부모 뷰의 너비입니다. 세로가 긴 이미지일 경우, 이 값을 기준으로 너비를 맞춥니다.
    /// - Returns: 이미지의 비율에 따라 적절한 사이즈와 콘텐츠 모드로 조정된 이미지 뷰를 반환합니다.
    @ViewBuilder
    private func imageView(for image: UIImage, parentWidth: CGFloat) -> some View {
        let width = image.size.width
        let height = image.size.height
        
        if width > height {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: size.height)
                .frame(maxWidth: parentWidth)
                .clipped()

        } else {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: parentWidth)
                .clipped()
        }
    }
}

struct ReactiveAsyncImage: View {
    @State private var uiImage: UIImage? = nil
    @State private var isLoading: Bool = true
    let url: String
    let scale: ImageScale
    let quality: CGFloat
    let downsampling: Bool
    
    var body: some View {
        Group {
            if let image = uiImage {
                Image(uiImage: image)
                    .resizable()
            } else {
                Color.border
                    .shimmer(when: $isLoading)
            }
        }
        .task {
            uiImage = try? await ImageLoader.loadFromURL(
                from: URL(string: url),
                size: .zero,
                scale: scale,
                quality: quality,
                downsampled: downsampling
            )
            
            isLoading = false
        }
    }
}
