//
//  NoteBalloonRenderer.swift
//  saerok
//
//  Created by HanSeung on 5/22/25.
//


import UIKit

enum NoteBalloonRenderer {

    static func make(note: String, birdName: String) -> UIImage {
        let maxWidth: CGFloat = 180
        let padding: CGFloat = 14
        let spacing: CGFloat = 6
        let tailHeight: CGFloat = 8
        let bottomSpacing: CGFloat = 60
        let shadowBlur: CGFloat = 3
        let shadowMargin: CGFloat = 9

        // ✅ 폰트
        let nameFont = UIFont(name: "MoneygraphyTTF-Rounded", size: 15)!
        let noteFont = UIFont(name: "PretendardVariable-Regular", size: 13)!

        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center

        let nameAttr: [NSAttributedString.Key: Any] = [
            .font: nameFont,
            .foregroundColor: UIColor.black,
            .paragraphStyle: paragraph
        ]

        // ✅ 새 이름 높이 계산
        let nameRect = (birdName as NSString).boundingRect(
            with: CGSize(width: maxWidth, height: .infinity),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: nameAttr,
            context: nil
        ).integral

        // ✅ 노트 UILabel
        let noteLabel = UILabel()
        noteLabel.numberOfLines = 2
        noteLabel.font = noteFont
        noteLabel.text = note
        noteLabel.textColor = .black
        noteLabel.textAlignment = .center
        noteLabel.lineBreakMode = .byTruncatingTail
        noteLabel.preferredMaxLayoutWidth = maxWidth
        let noteSize = noteLabel.sizeThatFits(CGSize(width: maxWidth, height: .greatestFiniteMagnitude))

        let contentWidth = max(nameRect.width, noteSize.width)
        let balloonWidth = contentWidth + padding * 2
        let balloonHeight = nameRect.height + spacing + noteSize.height + padding * 2
        let totalWidth = balloonWidth + shadowMargin * 2
        let totalHeight = balloonHeight + tailHeight + bottomSpacing + shadowMargin * 2

        UIGraphicsBeginImageContextWithOptions(CGSize(width: totalWidth, height: totalHeight), false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }

        // ✅ 그림자
        context.setShadow(offset: .zero, blur: shadowBlur, color: UIColor.black.withAlphaComponent(0.3).cgColor)

        // ✅ 본체 위치
        let bgRect = CGRect(x: shadowMargin, y: shadowMargin, width: balloonWidth, height: balloonHeight)
        let bgPath = UIBezierPath(roundedRect: bgRect, cornerRadius: 20)
        UIColor.white.setFill()
        bgPath.fill()

        // ✅ 꼬리
        context.setShadow(offset: .zero, blur: 0)
        let tailPath = UIBezierPath()
        tailPath.move(to: CGPoint(x: totalWidth / 2 - 6, y: bgRect.maxY))
        tailPath.addLine(to: CGPoint(x: totalWidth / 2, y: bgRect.maxY + tailHeight))
        tailPath.addLine(to: CGPoint(x: totalWidth / 2 + 6, y: bgRect.maxY))
        tailPath.close()
        UIColor.white.setFill()
        tailPath.fill()

        // ✅ 텍스트 위치
        let namePosition = CGRect(
            x: (totalWidth - nameRect.width) / 2,
            y: shadowMargin + padding,
            width: nameRect.width,
            height: nameRect.height
        )
        (birdName as NSString).draw(in: namePosition, withAttributes: nameAttr)

        let notePosition = CGRect(
            x: shadowMargin + padding,
            y: namePosition.maxY + spacing,
            width: balloonWidth - padding * 2,
            height: noteSize.height
        )
        noteLabel.frame = notePosition
        noteLabel.backgroundColor = .clear
        noteLabel.drawHierarchy(in: notePosition, afterScreenUpdates: true)

        // ✅ 이미지 추출
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    static func makeNoteBalloonView(note: String, birdName: String) -> UIView {
        let image = make(note: note, birdName: birdName)
        let imageView = UIImageView(image: image)
        imageView.backgroundColor = .clear
        imageView.contentMode = .center
        return imageView
    }
}
