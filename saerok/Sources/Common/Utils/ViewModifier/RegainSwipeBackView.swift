//
//  SwiftUIView.swift
//  saerok
//
//  Created by Hanseung on 4/10/25.
//

import SwiftUI
import UIKit

extension View {
    public func regainSwipeBack() -> some View {
        self
            .navigationBarHidden(true)
            .background(
            RegainSwipeBackView()
        )
    }
}

struct RegainSwipeBackView: UIViewControllerRepresentable {
    typealias UIViewControllerType = RegainSwipeBackViewController
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        UIViewControllerType()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
}

class RegainSwipeBackViewController: UIViewController {
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if let parent = parent?.parent,
           let navigationController = parent.navigationController {
            navigationController.interactivePopGestureRecognizer?.isEnabled = true
        }
    }
}

extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
