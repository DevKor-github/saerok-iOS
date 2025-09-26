//
//  ImageUploadPreprocessor.swift
//

import UIKit

struct ImageUploadPreprocessor {
    /// Prepares JPEG data for upload by downscaling the image to a maximum pixel dimension and compressing it.
    ///
    /// This function is intended for upload-time preprocessing only. It downsizes the image based on pixel dimensions
    /// and compresses it to JPEG format. It should NOT be used for UI display purposes.
    ///
    /// - Parameters:
    ///   - image: The original UIImage to process.
    ///   - maxPixel: The maximum allowed pixel dimension (width or height) after resizing. Defaults to 2048.
    ///   - quality: The JPEG compression quality, between 0.0 and 1.0. Defaults to 0.8.
    ///   - opaque: A Boolean flag indicating whether the image is opaque. Defaults to true.
    /// - Returns: JPEG data of the processed image, or nil if encoding fails.
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
}
