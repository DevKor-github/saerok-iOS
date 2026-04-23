//
//  SRToastModifier.swift
//  saerok
//
//  Created by HanSeung on 4/21/26.
//

import SwiftUI

struct SRToastModifier: ViewModifier {
    @State var activeToast: Toast?
    @State private var toastDismissWorkItem: DispatchWorkItem?
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if let activeToast {
                    toastView(activeToast)
                }
            }
            .environment(\.showToast) { toast in
                withAnimation(
                    animation.logicallyComplete(after: 0.17),
                    completionCriteria: .logicallyComplete
                ) {
                    if activeToast != nil {
                        activeToast = nil
                    }
                    
                } completion: {
                    toastDismissWorkItem?.cancel()
                    withAnimation(animation) {
                        activeToast = toast
                    }
                    toastDismissWorkItem = .init(block: dismiss)
                    let duration = max(toast.duration, 1)
                    if let toastDismissWorkItem {
                        DispatchQueue.main.asyncAfter(
                            deadline: .now() + duration,
                            execute: toastDismissWorkItem
                        )
                    }
                }
            }
    }
    
    private let animation: Animation = .interpolatingSpring(duration: 0.35, bounce: 0, initialVelocity: 0)
    
    private func toastView(_ toast: Toast) -> some View {
        HStack(alignment: .center, spacing: 7) {
            if let image = toast.type.image {
                image
                    .resizable()
                    .foregroundStyle(.srWhite)
                    .padding(2)
                    .frame(width: 25, height: 25, alignment: .center)
                    .cornerRadius(8)
                    .transition(.identity)
            } else {
                Color.clear.frame(width: 1, height: 10)
            }
            
            Text(toast.message)
                .font(.SRFontSet.body2)
                .multilineTextAlignment(.center)
                .frame(height: 28)
            
            Image(systemName: "xmark")
                .resizable()
                .frame(width: 10, height: 10)
                .foregroundStyle(.srGray)
                .onTapGesture(perform: dismiss)
                .transition(.identity)
        }
        .padding(.leading, 6)
        .padding(.trailing, 13)
        .padding(.vertical, 5)
        .background(
            Color.white.opacity(0.8)
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .inset(by: 0.5)
                .stroke(toast.type.strokeColor, lineWidth: 1)
        )
        .offset(y: toast.placementOffset)
        .gesture(
            DragGesture()
                .onEnded { value in
                    let endTranslation = value.translation.height
                    if endTranslation > 30 {
                        dismiss()
                    }
                }
        )
        .transition(.offset(y: toast.transitionOffset))
    }
    
    private func dismiss() {
        withAnimation(animation) {
            activeToast = nil
        }
        toastDismissWorkItem?.cancel()
    }
}

struct Toast {
    let id = UUID().uuidString
    let type: ToastType
    let message: String
    let placementOffset: CGFloat
    let transitionOffset: CGFloat
    let duration: CGFloat
}

enum ToastType {
    case success
    case failure
    case normal
    
    var image: Image? {
        switch self {
        case .success:
            return Image(.toastSuccess)
        case .failure:
            return Image(.toastFailure)
        case .normal:
            return nil
        }
    }
    
    var color: Color {
        switch self {
        case .success: .splash
        case .failure: .iconRed
        case .normal: .srGray
        }
    }
    
    var strokeColor: Color {
        switch self {
        case .success: .accent
        case .failure: .fire
        case .normal: .srGray
        }
    }
}

extension View {
    func srToast() -> some View {
        modifier(
            SRToastModifier()
        )
    }
}

extension EnvironmentValues {
    @Entry var showToast: (Toast) -> () = { _ in }
}
