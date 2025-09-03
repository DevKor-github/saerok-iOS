//
//  ImageLoader.swift
//  saerok
//
//  Created by HanSeung on 4/12/25.
//


import Foundation
import UIKit

enum ImageLoaderError: Error {
    case failedToDownload
}

public enum ImageScale: CGFloat {
    case small = 1
    case medium = 2
    case large = 3
}

enum ImageLoader {
    static func loadFromURL(
        from url: URL?,
        size: CGSize,
        scale: ImageScale = .small,
        quality: CGFloat = 0.8,
        downsampled: Bool = false
    ) async throws -> UIImage?
    {
        guard let url = url else { return nil }
        
        let cacheKey = url.absoluteString + "\(downsampled ? 0 : 1)"
        if let cachedImage = cachedImage(for: cacheKey) { return cachedImage }
        let image = try await downloadImage(from: url)
        let finalImage = downsampled ? downsampling(image, size: size, scale: scale, quality: quality) : image

        cacheImage(finalImage, for: cacheKey)
        return finalImage
    }
}

private extension ImageLoader {
    static func downloadImage(from url: URL) async throws -> UIImage {
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let image = UIImage(data: data)
        else { throw ImageLoaderError.failedToDownload }
        
        return image
    }
    
    static func cachedImage(for key: String) -> UIImage? {
        guard let cachedImage = ImageCache.shared.get(forKey: key) else { return nil }
        
        return cachedImage
    }
    
    static func cacheImage(_ image: UIImage, for key: String) {
        ImageCache.shared.set(image, forKey: key)
    }
    
    static func downsampling(_ image: UIImage, size: CGSize, scale: ImageScale, quality: CGFloat) -> UIImage {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        
        guard let data = image.jpegData(compressionQuality: quality),
              let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else {
            return image
        }
        
        let thumbnailMaxPixelSize = max(size.width, size.height) * scale.rawValue
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: thumbnailMaxPixelSize,
        ] as CFDictionary

        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return image
        }
        
        return UIImage(cgImage: downsampledImage)
    }
}
