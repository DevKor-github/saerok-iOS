//
//  NoteBalloonRenderer.swift
//  saerok
//
//  Created by HanSeung on 5/22/25.
//


import UIKit

enum NoteBalloonRenderer {

    static func make(note: String, birdName: String) -> UIImage {
        // 말풍선 크기 제한
        let minBalloonWidth: CGFloat = 71
        let maxBalloonWidth: CGFloat = 198
        
        // 레이블영역 패딩
        let verticalPaddingTop: CGFloat = 11
        let verticalPaddingBottom: CGFloat = 9
        let horizontalPadding: CGFloat = 13
        
        // 꼬리 높이, 그림자 등 기존 상수 유지
        let spacing: CGFloat = 6
        let tailHeight: CGFloat = 8
        let bottomSpacing: CGFloat = 60
        let shadowBlur: CGFloat = 3
        let shadowMargin: CGFloat = 9
        
        // 폰트
        let nameFont = UIFont(name: "MoneygraphyTTF-Rounded", size: 15)!
        let noteFont = UIFont(name: "PretendardVariable-Regular", size: 13)!
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        let nameAttr: [NSAttributedString.Key: Any] = [
            .font: nameFont,
            .foregroundColor: UIColor.black,
            .paragraphStyle: paragraph
        ]
        
        // 먼저, 최대 너비에서 텍스트 측정 (최대 너비 - 수평 패딩 * 2)
        let maxContentWidth = maxBalloonWidth - horizontalPadding * 2
        
        // 새 이름 크기 측정 (너비 제한)
        let nameRect = (birdName as NSString).boundingRect(
            with: CGSize(width: maxContentWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: nameAttr,
            context: nil
        ).integral
        
        // 노트 UILabel 구성 (numberOfLines = 2)
        let noteLabel = UILabel()
        noteLabel.numberOfLines = 2
        noteLabel.font = noteFont
        noteLabel.text = note
        noteLabel.textColor = .black
        noteLabel.textAlignment = .center
        noteLabel.lineBreakMode = .byTruncatingTail
        noteLabel.preferredMaxLayoutWidth = maxContentWidth
        let noteSize = noteLabel.sizeThatFits(CGSize(width: maxContentWidth, height: .greatestFiniteMagnitude))
        
        // 레이블영역 크기 (네임 + spacing + 노트)
        let labelContentWidth = max(nameRect.width, noteSize.width)
        let labelContentHeight = nameRect.height + spacing + noteSize.height
        
        // 레이블영역 전체 크기 (패딩 포함)
        let labelAreaWidth = labelContentWidth + horizontalPadding * 2
        let labelAreaHeight = labelContentHeight + verticalPaddingTop + verticalPaddingBottom
        
        // 말풍선 본체 너비는 labelAreaWidth 제한 내에서 min, max 조정
        let balloonWidth = max(minBalloonWidth, min(labelAreaWidth, maxBalloonWidth))
        
        // 말풍선 본체 높이 = 레이블영역 높이
        let balloonHeight = labelAreaHeight
        
        let totalWidth = balloonWidth + shadowMargin * 2
        let totalHeight = balloonHeight + tailHeight + bottomSpacing + shadowMargin * 2
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: totalWidth, height: totalHeight), false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }
        
        // 그림자
        context.setShadow(offset: .zero, blur: shadowBlur, color: UIColor.black.withAlphaComponent(0.3).cgColor)
        
        // 본체 위치
        let bgRect = CGRect(x: shadowMargin, y: shadowMargin, width: balloonWidth, height: balloonHeight)
        let bgPath = UIBezierPath(roundedRect: bgRect, cornerRadius: 19)
        UIColor.white.setFill()
        bgPath.fill()
        
        // 꼬리
        context.setShadow(offset: .zero, blur: 0)
        let tailPath = UIBezierPath()
        tailPath.move(to: CGPoint(x: totalWidth / 2 - 6, y: bgRect.maxY))
        tailPath.addLine(to: CGPoint(x: totalWidth / 2, y: bgRect.maxY + tailHeight))
        tailPath.addLine(to: CGPoint(x: totalWidth / 2 + 6, y: bgRect.maxY))
        tailPath.close()
        UIColor.white.setFill()
        tailPath.fill()
        
        // 텍스트 위치 (가로는 bgRect 내부에 맞춤, 세로는 top padding 위치)
        let namePosition = CGRect(
            x: shadowMargin + (balloonWidth - nameRect.width) / 2,
            y: shadowMargin + verticalPaddingTop,
            width: nameRect.width,
            height: nameRect.height
        )
        (birdName as NSString).draw(in: namePosition, withAttributes: nameAttr)
        
        let notePosition = CGRect(
            x: shadowMargin + horizontalPadding,
            y: namePosition.maxY + spacing,
            width: balloonWidth - horizontalPadding * 2,
            height: noteSize.height
        )
        noteLabel.frame = notePosition
        noteLabel.backgroundColor = .clear
        noteLabel.drawHierarchy(in: notePosition, afterScreenUpdates: true)
        
        // 이미지 추출
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
