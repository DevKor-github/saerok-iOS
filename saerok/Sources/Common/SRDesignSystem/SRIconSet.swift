//
//  SRIconSet.swift
//  saerok
//
//  Created by HanSeung on 3/18/25.
//


import SwiftUI

extension Image {
    enum SRIconSet: String, Hashable {
        
        // MARK: SFSymbol

        case chevronLeft
        case chevronRight
        case iconAdd
        case down
        case xmark
        case xmarkCircleFill
        case penFill
        case textFormat
        case magnifyingGlass
        
        // MARK: Custom Symbol

        case scrap
        case scrapFilled
        case season
        case seasonWhite
        case size
        case sizeWhite
        case habitat
        case habitatWhite
        case bookmark
        case bookmarkFilled
        case alert
        
        // MARK: Tabbar
        case doongzi
        case doongziFilled
        case dogam
        case dogamFilled
        case heart
        case heartFilled
        case my
        case myFilled
        case home
        case homeFilled
        
        // MARK: - Metric
        
        enum Metric: String {
            case defaultIconSizeSmall
            case defaultIconSize
            case defaultIconSizeLarge
            case defaultIconSizeVeryLarge
            
            func toCGSize() -> CGSize {
                switch self {
                case .defaultIconSizeSmall:
                    return CGSize(width: 13, height: 13)
                case .defaultIconSize:
                    return CGSize(width: 17, height: 17)
                case .defaultIconSizeLarge:
                    return CGSize(width: 24, height: 24)
                case .defaultIconSizeVeryLarge:
                    return CGSize(width: 42, height: 42)
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
        case .chevronLeft:
            return Image(systemName: "chevron.left")
        case .chevronRight:
            return Image(systemName: "chevron.right")
        case .magnifyingGlass:
            return Image(systemName: "magnifyingglass")
        case .xmark:
            return Image(systemName: "xmark")
        case .xmarkCircleFill:
            return Image(systemName: "xmark.circle.fill")
        case .scrap:
            return Image(.scrap)
        case .scrapFilled:
            return Image(.scrapFilled)
        case .season:
            return Image(.season)
        case .seasonWhite:
            return Image(.seasonWhite)
        case .size:
            return Image(.birdSize)
        case .sizeWhite:
            return Image(.sizeWhite)
        case .habitat:
            return Image(.habitat)
        case .habitatWhite:
            return Image(.habitatWhite)
        case .alert:
            return Image(.alert)
        case .bookmark:
            return Image(.bookmark)
        case .bookmarkFilled:
            return Image(.bookmarkFilled)
        case .penFill:
            return Image(.penFill)
        case .textFormat:
            return Image(systemName: "textformat")
        case .down:
            return Image(systemName: "chevron.down")
        case .dogam:
            return Image(.dogam)
        case .dogamFilled:
            return Image(.dogamFilled)
        case .heart:
            return Image(.heart)
        case .heartFilled:
            return Image(.heartFilled)
        case .my:
            return Image(.my)
        case .myFilled:
            return Image(.myFilled)
        case .home:
            return Image(.home)
        case .homeFilled:
            return Image(.homeFilled)
        case .doongzi:
            return Image(.doongzi)
        case .doongziFilled:
            return Image(.doongziFilled)
        default:
            return Image(self.rawValue, bundle: Image.SRIconSet.bundle)
        }
    }
}

