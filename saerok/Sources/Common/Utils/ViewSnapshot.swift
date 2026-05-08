//
//  ViewSnapshot.swift
//  saerok
//
//  Created by HanSeung on 6/11/25.
//


import SwiftUI

extension View {
    func snapshot(size: CGSize) -> UIImage {
        let controller = UIHostingController(rootView: self.ignoresSafeArea(.all))
        let view = controller.view!
        view.bounds = CGRect(origin: .zero, size: size)
        view.backgroundColor = .clear

        view.setNeedsLayout()
        view.layoutIfNeeded()

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
    }
}
