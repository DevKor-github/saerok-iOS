//
//  ImageCache.swift
//  saerok
//
//  Created by HanSeung on 4/12/25.
//

import UIKit

final class ImageCache: @unchecked Sendable {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {
        cache.countLimit = 50
        cache.totalCostLimit = 50 * 1024 * 1024
    }
    
    func get(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }
    
    func set(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString, cost: image.estimatedMemoryCost)
    }
}

private extension UIImage {
    /// NSCache.totalCostLimit 산정을 위한 추정 메모리 비용(바이트).
    /// 디코드된 비트맵 크기 ≈ 픽셀 수 × 4바이트(RGBA).
    var estimatedMemoryCost: Int {
        let pixelWidth = size.width * scale
        let pixelHeight = size.height * scale
        return Int(pixelWidth * pixelHeight) * 4
    }
}
