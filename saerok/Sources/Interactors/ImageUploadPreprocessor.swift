//
//  ImageUploadPreprocessor.swift
//

import Foundation
import ImageIO
import CoreGraphics
import UniformTypeIdentifiers
import UIKit

struct ImageUploadPreprocessor {
    
    static func prepareJPEGDataForUpload(
        from image: UIImage,
        maxPixel: CGFloat = 2048,
        quality: CGFloat = 0.8,
        opaque: Bool = true
    ) -> Data? {
        let pixelWidth = image.size.width * image.scale
        let pixelHeight = image.size.height * image.scale
        let maxSide = max(pixelWidth, pixelHeight)
        
        if maxSide <= maxPixel {
            return image.jpegData(compressionQuality: quality)
        } else {
            let s = maxPixel / maxSide
            let newPixelSize = CGSize(width: pixelWidth * s, height: pixelHeight * s)
            
            let format = UIGraphicsImageRendererFormat()
            format.scale = 1
            format.opaque = opaque
            format.preferredRange = .standard
            
            let renderer = UIGraphicsImageRenderer(size: newPixelSize, format: format)
            
            return autoreleasepool {
                let resized = renderer.image { _ in
                    image.draw(in: CGRect(origin: .zero, size: newPixelSize))
                }
                
                return resized.jpegData(compressionQuality: quality)
            }
        }
    }
    
    static func prepareJPEGDataForUpload(
        from imageData: Data,
        maxPixel: CGFloat = 2048,
        quality: CGFloat = 0.8
    ) -> Data? {

        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil) else {
            return nil
        }

        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixel,
            kCGImageSourceCreateThumbnailWithTransform: true
        ]

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            return nil
        }

        let outputData = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            outputData,
            UTType.jpeg.identifier as CFString,
            1,
            nil
        ) else {
            return nil
        }

        let compressionOptions: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: quality
        ]

        CGImageDestinationAddImage(destination, cgImage, compressionOptions as CFDictionary)

        guard CGImageDestinationFinalize(destination) else {
            return nil
        }

        return outputData as Data
    }
}
