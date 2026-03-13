//
//  FullImageOverlayModifier.swift
//  saerok
//
//  Created by HanSeung on 10/8/25.
//

import SwiftUI

struct FullImageOverlayModifier: ViewModifier {
    @Binding var isPresented: Bool
    let image: UIImage?

    func body(content: Content) -> some View {
        content
            .overlay {
                if isPresented, let image {
                    ZStack {
                        Color.black.opacity(0.95)
                            .ignoresSafeArea()
                            .onTapGesture { close() }
                        
                        ZoomableImageView(image: image) { close() }
                            .ignoresSafeArea()
                        
                        navigationButton
                    }
                    .transition(.opacity)
                    .zIndex(100)
                }
            }
    }

    private var navigationButton: some View {
        VStack {
            HStack {
                NavigationBar(
                    leading: {
                        Button(action: close) {
                            Image.SRIconSet.xmark
                                .frame(.defaultIconSize)
                        }
                        .srStyled(.iconButton)
                    },
                    backgroundColor: .clear
                )
                Spacer()
            }
            Spacer()
        }
    }
    
    private func close() {
        withAnimation(.easeInOut(duration: 0.25)) {
            isPresented = false
        }
    }
}

extension View {
    func fullImageOverlay(isPresented: Binding<Bool>, image: UIImage?) -> some View {
        modifier(FullImageOverlayModifier(isPresented: isPresented, image: image))
    }
}
