//
//  SRToastModifier.swift
//  saerok
//
//  Created by HanSeung on 4/21/26.
//

import SwiftUI

struct SRToastModifier: ViewModifier {
    @State private var toastAction = ToastAction()

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if let activeToast = toastAction.activeToast {
                    toastView(activeToast)
                        .id(activeToast.id)
                }
            }
            .environment(\.showToast, toastAction)
    }

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
                .foregroundStyle(toast.type.textColor)
                .multilineTextAlignment(.center)
                .frame(height: 28)
            
            Image(systemName: "xmark")
                .resizable()
                .frame(width: 10, height: 10)
                .foregroundStyle(.srGray)
                .onTapGesture { toastAction.dismiss() }
                .transition(.identity)
        }
        .padding(.leading, 6)
        .padding(.trailing, 13)
        .padding(.vertical, 5)
        .background(toast.type.backgroundColor)
        .background {
            BackdropView()
                .blur(radius: 4)
        }
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .inset(by: 0.5)
                .stroke(toast.type.strokeColor, lineWidth: 1)
        )
        .applyIf(toast.type == .normal) {
            $0.shadow(color: Color(red: 0.33, green: 0.33, blue: 0.33).opacity(0.5), radius: 5, x: 0, y: 0)
        }
        .offset(y: toast.placementOffset)
        .gesture(
            DragGesture()
                .onEnded { value in
                    let endTranslation = value.translation.height
                    if endTranslation > 30 {
                        toastAction.dismiss()
                    }
                }
        )
        .transition(.offset(y: toast.transitionOffset))
    }
}

/// 토스트 상태를 보관하고 표시/해제를 처리하는 안정적인 참조 타입.
/// 환경값으로 클로저 대신 이 객체를 주입해 consumer의 무한 재평가를 막는다.
/// `callAsFunction` 으로 기존 `showToast(.init(...))` 호출부를 그대로 유지한다.
@Observable
final class ToastAction {
    private(set) var activeToast: Toast?

    @ObservationIgnored private var toastDismissTask: Task<Void, Never>?
    @ObservationIgnored private let animation: Animation = .interpolatingSpring(duration: 0.35, bounce: 0, initialVelocity: 0)

    func callAsFunction(_ toast: Toast) {
        withAnimation(
            animation.logicallyComplete(after: 0.17),
            completionCriteria: .logicallyComplete
        ) {
            if activeToast != nil {
                activeToast = nil
            }
        } completion: {
            self.toastDismissTask?.cancel()
            withAnimation(self.animation) {
                self.activeToast = toast
            }
            let duration = max(toast.duration, 1)
            self.toastDismissTask = Task { [weak self] in
                do {
                    try await Task.sleep(for: .seconds(duration))
                    self?.dismiss()
                } catch { }
            }
        }
    }

    func dismiss() {
        withAnimation(animation) {
            activeToast = nil
        }
        toastDismissTask?.cancel()
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
    
    var iconColor: Color {
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
        case .normal: Color(red: 0.13, green: 0.13, blue: 0.13).opacity(0.8)
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .success: Color.white.opacity(0.8)
        case .failure: Color.white.opacity(0.8)
        case .normal: Color(red: 0.13, green: 0.13, blue: 0.13).opacity(0.8)
        }
    }
    
    var textColor: Color {
        switch self {
        case .success: .black
        case .failure: .black
        case .normal: .white
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
    @Entry var showToast = ToastAction()
}
