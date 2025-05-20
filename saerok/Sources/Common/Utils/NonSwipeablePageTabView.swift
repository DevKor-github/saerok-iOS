//
//  NonSwipeablePageTabView.swift
//  saerok
//
//  Created by HanSeung on 5/18/25.
//


import SwiftUI
import UIKit

struct NonSwipeablePageTabView<Content: View>: UIViewControllerRepresentable {
    @Binding var currentPage: Int
    let pages: [Content]

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let controller = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )

        controller.setViewControllers(
            [context.coordinator.controllers[currentPage]],
            direction: .forward,
            animated: false,
            completion: nil
        )

        controller.dataSource = nil
        controller.delegate = context.coordinator
        controller.view.subviews.forEach {
            if let scrollView = $0 as? UIScrollView {
                scrollView.isScrollEnabled = false
            }
        }

        return controller
    }

    func updateUIViewController(_ uiViewController: UIPageViewController, context: Context) {
        uiViewController.setViewControllers(
            [context.coordinator.controllers[currentPage]],
            direction: .forward,
            animated: true,
            completion: nil
        )
    }

    class Coordinator: NSObject, UIPageViewControllerDelegate {
        var parent: NonSwipeablePageTabView
        var controllers: [UIViewController]

        init(_ parent: NonSwipeablePageTabView) {
            self.parent = parent
            self.controllers = parent.pages.map { UIHostingController(rootView: $0) }
        }
    }
}
