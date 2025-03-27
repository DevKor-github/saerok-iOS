//
//  DefaultItemStyle.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//

import SwiftUI

struct DefaultItemStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.blue)
            .cornerRadius(SRDesignConstant.cornerRadius)
    }
}
