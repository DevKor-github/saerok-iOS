//
//  SRIconSet.swift
//  saerok
//
//  Created by HanSeung on 3/18/25.
//

import SwiftUI

extension Image {
    enum SRIconSet: String, Hashable {
        case iconAdd
        case down
        
        // Tabbar
        case ellipsisMessage
        case book
        case heart
        case house
        case person
        
        // MARK: - Metric
        
        enum Metric: String {
            case defaultIconSizeVerySmall
            case defaultIconSizeSmall
            case defaultIconSizeMedium
            case defaultIconSize
            case defaultIconSizeLarge
            case defaultIconSizeVeryLarge
            case quotedMessageIconSize
            case iconEmojiSmall
            case iconEmojiLarge
            
            func toCGSize() -> CGSize {
                switch self {
                case .defaultIconSizeVerySmall:
                    return CGSize(width: 12, height: 12)
                case .defaultIconSizeSmall:
                    return CGSize(width: 16, height: 16)
                case .defaultIconSizeMedium:
                    return CGSize(width: 18, height: 18)
                case .defaultIconSize:
                    return CGSize(width: 24, height: 24)
                case .defaultIconSizeLarge:
                    return CGSize(width: 32, height: 32)
                case .defaultIconSizeVeryLarge:
                    return CGSize(width: 48, height: 48)
                case .quotedMessageIconSize:
                    return CGSize(width: 20, height: 20)
                case .iconEmojiSmall:
                    return CGSize(width: 20, height: 20)
                case .iconEmojiLarge:
                    return CGSize(width: 38, height: 38)
                }
            }
        }
        
        // MARK: - Image Handling
        
        private static let bundle = Bundle(identifier: SRConstant.bundleIdentifier)

        /// 지정된 크기로 조정된 이미지를 반환. 선택적으로 틴트 색상을 적용할 수 있음
        /// - Parameters:
        ///   - size: 적용할 크기 (CGSize)
        ///   - tintColor: 선택적으로 적용할 틴트 색상 (기본값: `nil`)
        /// - Returns: 크기가 조정되고, 필요하면 색상이 적용된 SwiftUI 뷰
        @ViewBuilder
        func frame(size: CGSize, tintColor: Color? = nil) -> some View {
            let imageView = image
                .resizable()
                .scaledToFit()
                .frame(width: size.width, height: size.height)
            
            if let tintColor = tintColor {
                imageView.foregroundStyle(tintColor)
            } else {
                imageView
            }
        }
        
        func frame(_ metric: SRIconSet.Metric, tintColor: Color? = nil) -> some View {
            return frame(size: metric.toCGSize(), tintColor: tintColor)
        }
    }
}

// MARK: - Private Properties

extension Image.SRIconSet {
    /// 현재 아이콘에 해당하는 이미지를 반환하는 계산 프로퍼티
    /// - 반환: `Image` 객체
    private var image: Image {
        switch self {
        case .down:
            return Image(.chevronDown)
        case .book:
            return Image(.book)
        case .ellipsisMessage:
            return Image(.ellipsisMessage)
        case .heart:
            return Image(.heart)
        case .person:
            return Image(.person)
        case .house:
            return Image(.house)
        default:
            return Image(self.rawValue, bundle: Image.SRIconSet.bundle)
        }
    }
}

