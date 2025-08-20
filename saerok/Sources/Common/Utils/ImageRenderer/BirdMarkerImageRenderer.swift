//
//  BirdMarkerImageRenderer.swift
//  saerok
//
//  Created by HanSeung on 5/22/25.
//


import UIKit

enum BirdMarkerImageRenderer {
    static func make(from original: UIImage,
                     backgroundDiameter: CGFloat = 60,
                     imageDiameter: CGFloat = 54,
                     shadowBlur: CGFloat = 6) -> UIImage {
        let shadowPadding: CGFloat = shadowBlur * 2
        let canvasSize = CGSize(width: backgroundDiameter + shadowPadding,
                                height: backgroundDiameter + shadowPadding)
        
        let renderer = UIGraphicsImageRenderer(size: canvasSize)
        
        return renderer.image { context in
            let ctx = context.cgContext
            let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
            
            let backgroundRect = CGRect(
                x: center.x - backgroundDiameter / 2,
                y: center.y - backgroundDiameter / 2,
                width: backgroundDiameter,
                height: backgroundDiameter
            )
            
            let imageRect = CGRect(
                x: center.x - imageDiameter / 2,
                y: center.y - imageDiameter / 2,
                width: imageDiameter,
                height: imageDiameter
            )
            
            ctx.setShadow(offset: CGSize(width: 0, height: 2),
                          blur: shadowBlur,
                          color: UIColor.black.withAlphaComponent(0.25).cgColor)
            
            ctx.setFillColor(UIColor.white.cgColor)
            ctx.fillEllipse(in: backgroundRect)
            
            ctx.setShadow(offset: .zero, blur: 0, color: nil)
                        
            let squared = original.croppedSquare()
            let path = UIBezierPath(ovalIn: imageRect)
            path.addClip()
            squared.draw(in: imageRect)
        }
    }
}

extension UIImage {
    func croppedSquare() -> UIImage {
        let size = min(self.size.width, self.size.height)
        let originX = (self.size.width - size) / 2.0
        let originY = (self.size.height - size) / 2.0
        let cropRect = CGRect(x: originX, y: originY, width: size, height: size)

        guard let cgImage = self.cgImage?.cropping(to: cropRect) else {
            return self
        }
        return UIImage(cgImage: cgImage, scale: self.scale, orientation: self.imageOrientation)
    }
}
