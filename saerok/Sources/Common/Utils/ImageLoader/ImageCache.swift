//
//  ImageCache.swift
//  saerok
//
//  Created by HanSeung on 4/12/25.
//


import SwiftUI

final class ImageCache {
    nonisolated(unsafe) static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {
        cache.countLimit = 50
        cache.totalCostLimit = 50 * 1024 * 1024
    }
    
    public func get(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    public func set(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}
