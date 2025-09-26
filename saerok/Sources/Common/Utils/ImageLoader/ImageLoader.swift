//
//  ImageLoader.swift
//  saerok
//
//  Created by HanSeung on 4/12/25.
//


import Foundation
import UIKit
import ImageIO

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
        downsampled: Bool = false
    ) async throws -> UIImage? {
        guard let url = url else { return nil }
        
        let cacheKey = url.absoluteString + "\(Int(size.width))x\(Int(size.height))" + "\(scale.rawValue)"
        if let cachedImage = cachedImage(for: cacheKey) {
            return cachedImage
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let image: UIImage?
        if downsampled {
            image = downsampledImage(data: data, size: size, scale: scale)
        } else {
            image = UIImage(data: data) // 원본이 필요할 때만
        }
        
        if let image {
            cacheImage(image, for: cacheKey)
        }
        return image
    }
}

private extension ImageLoader {
    static func cachedImage(for key: String) -> UIImage? {
        ImageCache.shared.get(forKey: key)
    }
    
    static func cacheImage(_ image: UIImage, for key: String) {
        ImageCache.shared.set(image, forKey: key)
    }
    
    /// Data → CGImageSource → 다운샘플링된 UIImage
    static func downsampledImage(data: Data, size: CGSize, scale: ImageScale) -> UIImage? {
        let cfData = data as CFData
        guard let imageSource = CGImageSourceCreateWithData(cfData, nil) else { return nil }
        
        let maxDimensionInPixels = max(size.width, size.height) * UIScreen.main.scale * scale.rawValue
        
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels,
            kCGImageSourceCreateThumbnailWithTransform: true
        ]
        
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}
