//
//  ViewSnapshot.swift
//  saerok
//
//  Created by HanSeung on 6/11/25.
//


import SwiftUI

extension View {
    /// SwiftUI 뷰를 이미지로 렌더링한다.
    ///
    /// 과거에는 `UIHostingController` + `drawHierarchy(afterScreenUpdates:)`를 사용했으나,
    /// 윈도우에 부착되지 않은 오프스크린 뷰에서는 간헐적으로 빈(흰) 이미지가 렌더링되는
    /// 문제가 있었다. `ImageRenderer`는 뷰가 화면에 붙어있지 않아도 안정적으로 렌더링한다.
    @MainActor
    func snapshot(size: CGSize) -> UIImage {
        let renderer = ImageRenderer(content: self.frame(width: size.width, height: size.height))
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage ?? UIImage()
    }
}
