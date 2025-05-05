//
//  LottieView.swift
//  saerok
//
//  Created by HanSeung on 4/27/25.
//


import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let animationName: String
    let loopMode: LottieLoopMode
    let completion: (() -> Void)?

    init(animationName: String, loopMode: LottieLoopMode = .playOnce, completion: (() -> Void)? = nil) {
        self.animationName = animationName
        self.loopMode = loopMode
        self.completion = completion
    }

    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView(name: animationName)
        animationView.loopMode = loopMode
        animationView.contentMode = .scaleToFill
        animationView.play { finished in
            if finished {
                completion?()
            }
        }

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: view.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}
