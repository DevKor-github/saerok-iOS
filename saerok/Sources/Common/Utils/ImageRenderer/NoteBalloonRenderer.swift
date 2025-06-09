//
//  NoteBalloonRenderer.swift
//  saerok
//
//  Created by HanSeung on 5/22/25.
//


import UIKit

enum NoteBalloonRenderer {
    static func make(note: String) -> UIImage {
        let font = UIFont.systemFont(ofSize: 12, weight: .medium)
        let padding: CGFloat = 12
        let tailHeight: CGFloat = 8
        let bottomSpacing: CGFloat = 60
        let maxSize = CGSize(width: 150, height: CGFloat.infinity)

        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.black,
            .paragraphStyle: paragraph
        ]

        let textRect = (note as NSString).boundingRect(
            with: maxSize,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        ).integral

        let balloonHeight = textRect.height + padding * 2
        let totalHeight = balloonHeight + tailHeight + bottomSpacing
        let totalSize = CGSize(width: textRect.width + padding * 2, height: totalHeight)

        UIGraphicsBeginImageContextWithOptions(totalSize, false, 0)
        let context = UIGraphicsGetCurrentContext()!

        let bgPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: totalSize.width, height: balloonHeight), cornerRadius: 12)
        UIColor.white.setFill()
        context.setShadow(offset: CGSize(width: 0, height: 2), blur: 4, color: UIColor.black.withAlphaComponent(0.3).cgColor)
        bgPath.fill()

        context.setShadow(offset: .zero, blur: 0)
        let tailPath = UIBezierPath()
        tailPath.move(to: CGPoint(x: totalSize.width / 2 - 6, y: balloonHeight))
        tailPath.addLine(to: CGPoint(x: totalSize.width / 2, y: balloonHeight + tailHeight))
        tailPath.addLine(to: CGPoint(x: totalSize.width / 2 + 6, y: balloonHeight))
        tailPath.close()
        UIColor.white.setFill()
        tailPath.fill()

        let textRectPosition = CGRect(x: padding, y: padding, width: textRect.width, height: textRect.height)
        (note as NSString).draw(in: textRectPosition, withAttributes: attributes)

        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
