//
//  ImageLoader.swift
//  saerok
//
//  Created by HanSeung on 4/12/25.
//


import Foundation
import UIKit
import ImageIO
import CryptoKit

enum ImageLoaderError: Error {
    case failedToDownload
    case invalidMetadata
}

public struct ImageMetadata: Sendable {
    let width: Int
    let height: Int

    var aspectRatio: CGFloat {
        CGFloat(width) / CGFloat(height)
    }
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
        downsampled: Bool = false,
        isCachingEnabled: Bool = true,
        useDiskCache: Bool = false
    ) async throws -> UIImage? {
        guard let url = url else { return nil }

        let cacheKey = cacheKey(url: url, size: size, scale: scale)
        if isCachingEnabled, let cachedImage = cachedImage(for: cacheKey) {
            return cachedImage
        }
        if useDiskCache, let diskImage = await DiskImageCache.shared.image(for: cacheKey) {
            if isCachingEnabled { cacheImage(diskImage, for: cacheKey) }
            return diskImage
        }

        // 동일 키에 대한 동시 요청은 단일 다운로드로 합친다 (in-flight 중복 제거)
        return try await coalescer.image(for: cacheKey) {
            let (data, _) = try await URLSession.shared.data(from: url)

            let image: UIImage?
            if downsampled {
                image = downsampledImage(data: data, size: size, scale: scale)
            } else {
                image = UIImage(data: data) // 원본 필요할 때만
            }

            if let image {
                if isCachingEnabled { cacheImage(image, for: cacheKey) }
                if useDiskCache { await DiskImageCache.shared.store(image, for: cacheKey) }
            }
            return image
        }
    }

    /// 메타데이터(가로·세로)와 이미지를 **한 번의 다운로드로** 함께 반환한다.
    /// 캐시가 모두 채워져 있으면 다운로드 없이 즉시 반환한다.
    static func loadImageWithMetadata(
        from url: URL?,
        cellWidth: CGFloat,
        scale: ImageScale = .small,
        downsampled: Bool = true,
        isCachingEnabled: Bool = true
    ) async throws -> (image: UIImage?, metadata: ImageMetadata) {
        guard let url = url else { throw ImageLoaderError.failedToDownload }

        // 메타데이터가 캐시돼 있으면 다운로드 없이 사이즈 계산 → 이미지 로드(이미지도 캐시 히트면 무다운로드)
        if let metadata = await metadataCache.metadata(forKey: url.absoluteString) {
            let targetSize = targetSize(cellWidth: cellWidth, metadata: metadata)
            let image = try await loadFromURL(
                from: url,
                size: targetSize,
                scale: scale,
                downsampled: downsampled,
                isCachingEnabled: isCachingEnabled
            )
            return (image, metadata)
        }

        // 첫 로드: 한 번만 받아서 메타데이터 추출 + 다운샘플을 동일 데이터로 처리
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let metadata = metadata(from: data) else {
            throw ImageLoaderError.invalidMetadata
        }
        await metadataCache.set(metadata, forKey: url.absoluteString)

        let targetSize = targetSize(cellWidth: cellWidth, metadata: metadata)
        let cacheKey = cacheKey(url: url, size: targetSize, scale: scale)

        let image: UIImage?
        if downsampled {
            image = downsampledImage(data: data, size: targetSize, scale: scale)
        } else {
            image = UIImage(data: data)
        }
        if isCachingEnabled, let image {
            cacheImage(image, for: cacheKey)
        }
        return (image, metadata)
    }

    // MARK: - 메타데이터 추출
    static func fetchMetadata(from url: URL?) async throws -> ImageMetadata {
        guard let url = url else { throw ImageLoaderError.failedToDownload }

        if let cached = await metadataCache.metadata(forKey: url.absoluteString) {
            return cached
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let metadata = metadata(from: data) else {
            throw ImageLoaderError.invalidMetadata
        }
        await metadataCache.set(metadata, forKey: url.absoluteString)
        return metadata
    }
}

private extension ImageLoader {
    static let coalescer = ImageRequestCoalescer()
    static let metadataCache = ImageMetadataCache()

    static func cacheKey(url: URL, size: CGSize, scale: ImageScale) -> String {
        url.absoluteString + "\(Int(size.width))x\(Int(size.height))" + "\(scale.rawValue)"
    }

    static func targetSize(cellWidth: CGFloat, metadata: ImageMetadata) -> CGSize {
        let cellHeight = cellWidth / metadata.aspectRatio
        return CGSize(width: cellWidth, height: cellHeight)
    }

    static func cachedImage(for key: String) -> UIImage? {
        ImageCache.shared.get(forKey: key)
    }

    static func cacheImage(_ image: UIImage, for key: String) {
        ImageCache.shared.set(image, forKey: key)
    }

    static func metadata(from data: Data) -> ImageMetadata? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let width = properties[kCGImagePropertyPixelWidth] as? Int,
              let height = properties[kCGImagePropertyPixelHeight] as? Int else {
            return nil
        }
        return ImageMetadata(width: width, height: height)
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

// MARK: - In-flight 요청 중복 제거

/// 같은 캐시 키로 동시에 들어오는 다운로드 요청을 단일 Task로 합친다.
/// 스크롤 중 동일 이미지를 여러 셀이 요청해도 네트워크·디코드는 한 번만 수행된다.
private actor ImageRequestCoalescer {
    private var inFlight: [String: Task<UIImage?, Error>] = [:]

    func image(
        for key: String,
        load: @Sendable @escaping () async throws -> UIImage?
    ) async throws -> UIImage? {
        if let existing = inFlight[key] {
            return try await existing.value
        }
        let task = Task { try await load() }
        inFlight[key] = task
        defer { inFlight[key] = nil }
        return try await task.value
    }
}

// MARK: - 메타데이터 캐시

private actor ImageMetadataCache {
    private var store: [String: ImageMetadata] = [:]

    func metadata(forKey key: String) -> ImageMetadata? { store[key] }
    func set(_ metadata: ImageMetadata, forKey key: String) { store[key] = metadata }
}

// MARK: - 디스크 캐시 (도감 전용)

/// 도감 이미지처럼 반복적으로 보는 정적 이미지를 위한 디스크 캐시.
/// 앱을 재실행해도 재다운로드 없이 즉시 표시한다.
actor DiskImageCache {
    static let shared = DiskImageCache()

    private let directory: URL
    private let fileManager = FileManager.default

    private init() {
        let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        directory = caches.appendingPathComponent("FieldGuideImageCache", isDirectory: true)
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    func image(for key: String) -> UIImage? {
        let url = fileURL(for: key)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    func store(_ image: UIImage, for key: String) {
        guard let data = image.jpegData(compressionQuality: 0.9) ?? image.pngData() else { return }
        try? data.write(to: fileURL(for: key), options: .atomic)
    }

    private func fileURL(for key: String) -> URL {
        let digest = SHA256.hash(data: Data(key.utf8))
        let fileName = digest.map { String(format: "%02x", $0) }.joined()
        return directory.appendingPathComponent(fileName)
    }
}
