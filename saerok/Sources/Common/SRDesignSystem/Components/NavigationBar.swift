//
//  NavigationBar.swift
//  saerok
//
//  Created by HanSeung on 4/10/25.
//


import SwiftUI

struct NavigationBar<Center: View, Leading: View, Trailing: View>: View {
    
    // MARK: Properties
    
    private var center: Center
    private var leading: Leading
    private var trailing: Trailing
    
    private let backgroundColor: Color
    
    // MARK: Init

    init(
        @ViewBuilder
        center: () -> Center = { EmptyView() },
        leading: () -> Leading = { EmptyView() },
        trailing: () -> Trailing = { EmptyView() },
        backgroundColor: Color = .srWhite
    ) {
        self.center = center()
        self.leading = leading()
        self.trailing = trailing()
        self.backgroundColor = backgroundColor
    }

    var body: some View {
        ZStack {
            backgroundColor
            HStack(spacing: 0) {
                leading
                Spacer()
                trailing
            }
            .padding(.horizontal, SRDesignConstant.defaultPadding)
            HStack {
                center
            }
        }
        .foregroundStyle(Color.black)
        .frame(height: 62)
    }
}


#Preview {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    appDelegate.rootView
}
