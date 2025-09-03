//
//  CustomBottomSheetModifier.swift
//  saerok
//
//  Created by HanSeung on 7/13/25.
//

import SwiftUI

// MARK: - View Extension

extension View {
    func bottomSheet<SheetContent: View>(
        isShowing: Binding<Bool>? = nil,
        alwaysOnDisplay: Bool = false,
        topOffset: CGFloat = 100,
        backgroundColor: Color = .srLightGray,
        keyboard: KeyboardObserver,
        isExtendable: Bool = true,
        @ViewBuilder sheetContent: @escaping () -> SheetContent
    ) -> some View {
        self.modifier(
            BottomSheetModifier(
                isShowing: isShowing ?? .constant(true),
                alwaysOnDisplay: alwaysOnDisplay,
                topOffset: topOffset,
                backgroundColor: backgroundColor,
                sheetContent: sheetContent,
                currentDetent: alwaysOnDisplay ? .minimum : .medium,
                keyboard: keyboard,
                isExtendable: isExtendable
            )
        )
    }
}

// MARK: - Detent

enum BottomSheetDetent {
    case minimum
    case medium
    case large

    var height: CGFloat {
        switch self {
        case .minimum:
            170
        case .medium:
            UIScreen.main.bounds.height * 0.65
        case .large:
            UIScreen.main.bounds.height * 0.85
        }
    }
}

// MARK: - Bottom Sheet Modifier

struct BottomSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isShowing: Bool
    let alwaysOnDisplay: Bool
    let topOffset: CGFloat
    let backgroundColor: Color
    let sheetContent: () -> SheetContent
    
    @State private var dragOffset: CGFloat = 0
    @State var currentDetent: BottomSheetDetent
    @State private var bottomSheetSize: CGSize = .zero
    @ObservedObject var keyboard: KeyboardObserver
    let isExtendable: Bool

//    private var actualOffset: CGFloat {
//        if isShowing {
//            let base = UIScreen.main.bounds.height - currentDetent.height
//            return base + dragOffset
//        } else {
//            return UIScreen.main.bounds.height + 100
//        }
//    }

    private var actualOffset: CGFloat {
        guard isShowing else {
            return UIScreen.main.bounds.height + 100 // 항상 완전 숨김
        }
        
        let base = UIScreen.main.bounds.height - currentDetent.height
        return base + dragOffset
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            backgroundView
                .opacity(alwaysOnDisplay ? 0 : 1)
                
            foregroundView
        }
        .onChange(of: keyboard.keyboardHeight) { _, new in
            if (new > 0 && isExtendable && isShowing) && !alwaysOnDisplay {
                currentDetent = .large
            }
        }
        .onChange(of: isShowing) { _, new in
            if new == false {
                currentDetent = .medium
            }
        }
    }

    private var foregroundView: some View {
        VStack {
            Spacer()
            VStack(spacing: 0) {
                if isExtendable {
                    indicator
                } else {
                    Color.clear
                        .frame(height: 3)
                        .padding(.top, 5)
                }
                
                ZStack(alignment: .top) {
                    sheetContent()
                        .frame(maxHeight: UIScreen.main.bounds.height - topOffset)
                        .frame(width: UIScreen.main.bounds.width)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top)
                    Color.clear
                        .frame(width: 1)
                    PanGestureView(
                        onChanged: { translation in
                            switch currentDetent {
                            case .medium:
                                dragOffset = translation
                            case .large:
                                dragOffset = max(translation, 0)
                            case .minimum:
                                dragOffset = translation
                            }
                        },
                        onEnded: { translation in
                            withAnimation(.smooth) {
                                if translation > 40 {
                                    if currentDetent == .medium {
                                        if alwaysOnDisplay {
                                            currentDetent = .minimum
                                        } else {
                                            isShowing = false
                                        }
                                    } else {
                                        currentDetent = .medium
                                    }
                                } else if translation < -40 {
                                    currentDetent = .large
                                }
                            }
                            dragOffset = 0
                        }
                    )
                    .frame(width: 340, height: 60, alignment: .leading)
                    .allowsHitTesting(isShowing && isExtendable)
                }
            }
            .sizeState(size: $bottomSheetSize)
            .background(backgroundColor)
            .cornerRadius(20)
            .offset(y: actualOffset - dragOffset * 0.7)
            .shadow(color: .black.opacity(0.1), radius: 6)
            .animation(.smooth(duration: 0.2), value: isShowing)
            .animation(.smooth(duration: 0.2), value: currentDetent)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private var backgroundView: some View {
        Color.black.opacity(0.2)
            .ignoresSafeArea()
            .onTapGesture {
                withAnimation {
                    isShowing = false
                }
            }
            .transition(.opacity)
            .opacity(isShowing ? 1 : 0)
            .animation(.default, value: isShowing)
    }

    private let indicator: some View = {
        Capsule()
            .frame(width: 110, height: 3)
            .foregroundColor(.whiteGray)
            .padding(.top, 5)
    }()
}
