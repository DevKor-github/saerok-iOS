//
//  OnboardingOverlayModifier.swift
//  saerok
//
//  Created by HanSeung on 10/15/25.
//


import SwiftUI

struct OnboardingOverlayModifier: ViewModifier {
    let type: OnboardingType
    @State private var showOnboarding = false

    func body(content: Content) -> some View {
        ZStack {
            content

            if showOnboarding {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .transition(.opacity)

                OnboardingView(type: type) {
                    OnboardingStorage.setSeen(type)
                    withAnimation(.bouncy) {
                        showOnboarding = false
                    }
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            if !OnboardingStorage.hasSeen(type) {
                withAnimation(.easeInOut) {
                    showOnboarding = true
                }
            }
        }
        .onChange(of: type) { _, _ in
            if !OnboardingStorage.hasSeen(type) {
                withAnimation(.easeInOut) {
                    showOnboarding = true
                }
            } else {
                showOnboarding = false
            }
        }
    }
}

extension View {
    func onboardingOverlay(type: OnboardingType) -> some View {
        self.modifier(OnboardingOverlayModifier(type: type))
    }
}
