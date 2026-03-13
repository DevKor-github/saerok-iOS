//
//  ZoomableImageView.swift
//  saerok
//
//  Created by HanSeung on 10/8/25.
//


import SwiftUI

struct ZoomableImageView: UIViewRepresentable {
    let image: UIImage
    var onDismiss: (() -> Void)? = nil

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .clear
        scrollView.bouncesZoom = true
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.contentInsetAdjustmentBehavior = .never
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(imageView)
        context.coordinator.imageView = imageView
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])

        // 닫기용 제스처 (축소 중 아래로 드래그 시)
        let pan = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        pan.delegate = context.coordinator
        scrollView.addGestureRecognizer(pan)

        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIScrollViewDelegate, UIGestureRecognizerDelegate {
        var parent: ZoomableImageView
        weak var imageView: UIImageView?
        private var initialTranslation: CGFloat = 0
        private let dismissThreshold: CGFloat = 150

        init(_ parent: ZoomableImageView) {
            self.parent = parent
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return imageView
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            guard let imageView = imageView else { return }
            let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
            let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
            imageView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX,
                                       y: scrollView.contentSize.height * 0.5 + offsetY)
        }

        @objc func handlePan(_ sender: UIPanGestureRecognizer) {
            guard let scrollView = sender.view as? UIScrollView,
                  scrollView.zoomScale <= 1.05 else { return }

            let translation = sender.translation(in: scrollView)
            switch sender.state {
            case .changed:
                let offsetY = translation.y
                scrollView.transform = CGAffineTransform(translationX: 0, y: offsetY)
                let alpha = max(0, 0.95 - abs(offsetY) / 400)
                scrollView.superview?.backgroundColor = UIColor.black.withAlphaComponent(alpha)
            case .ended, .cancelled:
                if abs(translation.y) > dismissThreshold {
                    parent.onDismiss?()
                } else {
                    UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
                        scrollView.transform = .identity
                        scrollView.superview?.backgroundColor = UIColor.black.withAlphaComponent(0.95)
                    }
                }
            default:
                break
            }
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            true
        }
    }
}
