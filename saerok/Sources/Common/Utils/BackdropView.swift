//
//  BackdropView.swift
//  saerok
//
//  Created by HanSeung on 3/10/26.
//

import SwiftUI

/// 뒤에 있는 콘텐츠를 블러(backdrop blur) 처리하기 위한 커스텀 뷰.
/// Material API와 달리 블러 강도를 커스텀하기 위해 이용.
struct BackdropView: UIViewRepresentable {
//    func makeUIView(context: Context) -> UIVisualEffectView {
//        let view = UIVisualEffectView()
//        let blur = UIBlurEffect()
//        let animator = UIViewPropertyAnimator()
//        animator.addAnimations { view.effect = blur }
//        animator.fractionComplete = 0
//        animator.stopAnimation(false)
//        animator.finishAnimation(at: .current)
//        return view
//    }
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView()
        
        let blur = UIBlurEffect(style: .light)
        let animator = UIViewPropertyAnimator()
        animator.addAnimations { view.effect = blur }
        animator.fractionComplete = 0
        animator.stopAnimation(false)
        animator.finishAnimation(at: .current)
        
        let overlay = UIView()
        overlay.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        overlay.frame = view.bounds
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.contentView.addSubview(overlay)
        
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) { }
}
