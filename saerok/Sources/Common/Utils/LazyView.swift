//
//  LazyView.swift
//  saerok
//
//  Created by HanSeung on 5/28/25.
//


import SwiftUI

struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: some View {
        build()
    }
}
