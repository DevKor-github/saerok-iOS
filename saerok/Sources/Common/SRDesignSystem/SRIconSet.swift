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
        case bookmarkSecondary
        case alert
        case insta
        case download
        case share
        case search
        case searchSecondary
        case delete
        case floatingButton
        case floatingButtonInactive
        case option
        case pin
        case clock
        case upper
        case global
        case edit
        case reset
        case bell
        case locker
        case info
        case login
        case logout
        case checkboxMiniDefault
        case checkboxMiniChecked
        case checkboxMiniCheckedReverse
        case checkboxDefault
        case checkboxChecked
        case xmarkCircle
        case toDogam
        case airplane
        case jongchuMini
        case board
        case heart
        case heartFilled
        case comment
        case commentFilled
        case upperArrow
        case o
        case x
        case plus
        case adopt
        case plane
        
        // MARK: Tabbar
        case doongzi
        case doongziFilled
        case dogam
        case dogamFilled
        case saerok
        case saerokFilled
        case my
        case myFilled
        case home
        case homeFilled
        
        // MARK: - Metric
        
        enum Metric {
            case defaultIconSizeSmall
            case defaultIconSize
            case defaultIconSizeLarge
            case defaultIconSizeVeryLarge
            case floatingButton
            case custom(width: CGFloat, height: CGFloat)
            
            func toCGSize() -> CGSize {
                switch self {
                case .defaultIconSizeSmall:
                    return CGSize(width: 13, height: 13)
                case .defaultIconSize:
                    return CGSize(width: 17, height: 17)
                case .defaultIconSizeLarge:
                    return CGSize(width: 24, height: 24)
                case .defaultIconSizeVeryLarge:
                    return CGSize(width: 40, height: 40)
                case .floatingButton:
                    return CGSize(width: 61, height: 61)
                case let .custom(width, height):
                    return CGSize(width: width, height: height)
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
            if let tintColor = tintColor {
                image
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size.width, height: size.height)
                    .foregroundStyle(tintColor)
            } else {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: size.width, height: size.height)
            }
        }
        
        func frame(_ metric: SRIconSet.Metric, tintColor: Color? = nil) -> some View {
            return frame(size: metric.toCGSize(), tintColor: tintColor)
        }
    }
}

// MARK: - Private Properties

extension Image.SRIconSet {
    private var image: Image {
        switch self {
        case .chevronLeft: return Image(systemName: "chevron.left")
        case .chevronRight: return Image(systemName: "chevron.right")
        case .xmarkCircleFill: return Image(systemName: "xmark.circle.fill")
        case .scrap: return Image(.scrap)
        case .scrapFilled: return Image(.scrapFilled)
        case .season: return Image(.season)
        case .seasonWhite: return Image(.seasonWhite)
        case .size: return Image(.birdSize)
        case .sizeWhite: return Image(.sizeWhite)
        case .habitat: return Image(.habitat)
        case .habitatWhite: return Image(.habitatWhite)
        case .alert: return Image(.alert)
        case .insta: return Image(.insta)
        case .download: return Image(.download)
        case .share: return Image(.share)
        case .delete: return Image(.delete)
        case .edit: return Image(.edit)
        case .option: return Image(.option)
        case .pin: return Image(.pin)
        case .login: return Image(.login)
        case .logout: return Image(.logout)
        case .clock: return Image(.clock)
        case .reset: return Image(.reset)
        case .upper: return Image(.upper)
        case .floatingButton: return Image(.floatingButton)
        case .floatingButtonInactive: return Image(.floatingButtonInactive)
        case .search: return Image(.search)
        case .searchSecondary: return Image(.searchSecondary)
        case .global: return Image(.global)
        case .bookmark: return Image(.bookmark)
        case .bookmarkFilled: return Image(.bookmarkFilled)
        case .bookmarkSecondary: return Image(.bookmarkSecondary)
        case .penFill:  return Image(.penFill)
        case .checkboxChecked: return Image(.checkboxActive)
        case .checkboxDefault: return Image(.checkboxDefault)
        case .checkboxMiniChecked: return Image(.checkboxMiniActive)
        case .checkboxMiniDefault: return Image(.checkboxMiniDefault)
        case .checkboxMiniCheckedReverse: return Image(.checkboxMiniActiveReverse)
        case .xmarkCircle: return Image(.xmarkCircle)
        case .xmark: return Image(systemName: "xmark")
        case .toDogam: return Image(.toDogam)
        case .airplane: return Image(.airplane)
        case .textFormat: return Image(systemName: "textformat")
        case .down: return Image(systemName: "chevron.down")
        case .bell: return Image(.bell)
        case .info: return Image(.info)
        case .locker: return Image(.locke)
        case .jongchuMini: return Image(.jongchuMini)
        case .board: return Image(.board)
        case .heart: return Image(.heart)
        case .heartFilled: return Image(.heartFilled)
        case .comment: return Image(.comment)
        case .commentFilled: return Image(.commentFilled)
        case .upperArrow: return Image(.upperArrow)
        case .o: return Image(.o)
        case .x: return Image(.x)
        case .plus: return Image(.plus)
        case .adopt: return Image(.adopt)
        case .plane: return Image(.plane)
            
        case .dogam: return Image(.dogam)
        case .dogamFilled: return Image(.dogamFilled)
        case .saerok: return Image(.saerok)
        case .saerokFilled: return Image(.saerokFilled)
        case .my: return Image(.my)
        case .myFilled: return Image(.myFilled)
        case .home: return Image(.home)
        case .homeFilled: return Image(.homeFilled)
        case .doongzi: return Image(.doongzi)
        case .doongziFilled: return Image(.doongziFilled)
        default: return Image(self.rawValue, bundle: Image.SRIconSet.bundle)
        }
    }
}

