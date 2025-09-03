//
//  PanGestureView.swift
//  saerok
//
//  Created by HanSeung on 7/13/25.
//


import SwiftUI
import UIKit

struct PanGestureView: UIViewRepresentable {
    var onChanged: (CGFloat) -> Void
    var onEnded: (CGFloat) -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        let panGesture = UIPanGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePan(_:))
        )
        view.addGestureRecognizer(panGesture)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onChanged: onChanged, onEnded: onEnded)
    }
    
    class Coordinator: NSObject {
        let onChanged: (CGFloat) -> Void
        let onEnded: (CGFloat) -> Void
        
        init(onChanged: @escaping (CGFloat) -> Void, onEnded: @escaping (CGFloat) -> Void) {
            self.onChanged = onChanged
            self.onEnded = onEnded
        }
        
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            let translationY = gesture.translation(in: gesture.view).y
            
            switch gesture.state {
            case .changed:
                onChanged(translationY)
            case .ended, .cancelled:
                onEnded(translationY)
            default:
                break
            }
        }
    }
}