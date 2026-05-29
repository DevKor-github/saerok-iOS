//
//  AvatarStyle.swift
//  saerok
//
//  Created by HanSeung on 3/10/26.
//

import SwiftUI

struct SRAvatarStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: 25, height: 25)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .inset(by: 0.6)
                    .stroke(.srLightGray, lineWidth: 2)
            )            
    }
}

struct SRAvatarStyle_2: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: 21, height: 21)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .inset(by: 0.6)
                    .stroke(.srLightGray, lineWidth: 2)
            )
    }
}

extension View {
    func srAvatarStyle() -> some View {
        modifier(SRAvatarStyle())
    }
    
    func srAvatarStyle_2() -> some View {
        modifier(SRAvatarStyle_2())
    }
}
