//
//  KeyboardObserver.swift
//  saerok
//
//  Created by HanSeung on 7/14/25.
//


import Combine
import SwiftUI

final class KeyboardObserver: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { ($0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0 }

        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }

        willShow
            .merge(with: willHide)
            .receive(on: RunLoop.main)
            .assign(to: \.keyboardHeight, on: self)
            .store(in: &cancellables)
    }
}