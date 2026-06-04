//
//  RegainSwipeBackView.swift
//  saerok
//
//  Created by Hanseung on 4/10/25.
//

import SwiftUI
import UIKit

extension View {
    /// 네비게이션 바를 숨기면서도 엣지 스와이프 뒤로가기를 유지한다.
    ///
    /// UIKit은 네비게이션 바가 숨겨지면 `interactivePopGestureRecognizer`를 비활성화하므로,
    /// 제스처 델리게이트를 "팝할 화면이 있으면 허용"하도록 직접 설정해 되살린다.
    /// 델리게이트 설정은 `InteractivePopGestureEnabler` 부착 시 1회만 수행한다.
    public func regainSwipeBack() -> some View {
        self
            .toolbar(.hidden, for: .navigationBar)
            .background(InteractivePopGestureEnabler())
    }
}

/// NavigationStack의 `UINavigationController`에 부착돼,
/// 네비게이션 바가 숨겨진 상태에서도 엣지 스와이프 뒤로가기를 유지시킨다.
///
/// - 프레임워크 클래스(`UINavigationController`)를 extension에서 override하지 않는다.
///   (기존 `override open func viewDidLoad()`는 앱 내 모든 네비게이션 컨트롤러에
/// - 제스처 델리게이트로 nav 컨트롤러 자신이 아니라 전용 객체를 사용한다.
struct InteractivePopGestureEnabler: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        // navigationController는 뷰 계층 부착 이후에 잡히므로 다음 런루프에서 설정한다.
        DispatchQueue.main.async {
            guard let nav = viewController.navigationController else { return }
            let delegate = SwipeBackGestureDelegate.shared
            delegate.navigationController = nav
            nav.interactivePopGestureRecognizer?.delegate = delegate
            nav.interactivePopGestureRecognizer?.isEnabled = true
        }
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

/// 엣지 스와이프 뒤로가기 제스처의 시작 여부를 결정하는 전용 델리게이트.
///
/// 제스처 인식기는 델리게이트를 weak로 참조하므로, push/pop으로 화면이 교체돼도
/// 델리게이트가 사라지지 않도록 `static` 싱글톤으로 수명을 보장한다.
/// `viewControllers.count`를 매번 평가하므로 루트(=1개)에서는 자동으로 비활성된다.
final class SwipeBackGestureDelegate: NSObject, UIGestureRecognizerDelegate {
    static let shared = SwipeBackGestureDelegate()
    weak var navigationController: UINavigationController?

    private override init() {}

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        (navigationController?.viewControllers.count ?? 0) > 1
    }
}
