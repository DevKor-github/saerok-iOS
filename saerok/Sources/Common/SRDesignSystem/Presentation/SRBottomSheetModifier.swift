//
//  SRBottomSheetModifier.swift
//  saerok
//
//  Created by HanSeung on 9/15/25.
//


import SwiftUI

extension View {
    func srBottomSheet(presentationDetent det: Set<PresentationDetent> = [.medium, .large], backgroundColor: Color = .srLightGray) -> some View {
        self.modifier(SRBottomSheetModifier(detent: det, backgroundColor: backgroundColor))
    }
}

struct SRBottomSheetModifier: ViewModifier {
    let detent: Set<PresentationDetent>
    let backgroundColor: Color
    
    func body(content: Content) -> some View {
        content
            .presentationDetents(detent)
//            .presentationCornerRadius(30)
            .presentationBackground(backgroundColor)
            .presentationDragIndicator(.hidden)
            .ignoresSafeArea(edges: .bottom)
    }
}

let sheetIndicator: some View = {
    Capsule()
        .frame(width: 110, height: 3)
        .foregroundColor(.whiteGray)
        .padding(.top, 5)
}()
