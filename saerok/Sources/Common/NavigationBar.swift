//
//  NavigationBar.swift
//  saerok
//
//  Created by HanSeung on 4/10/25.
//


import SwiftUI

struct NavigationBar<Center: View, Leading: View, Trailing: View>: View {
    
    // MARK: Properties
    
    var center: Center
    var leading: Leading
    var trailing: Trailing
    
    // MARK: Init

    init(
        @ViewBuilder
        center: () -> Center = { EmptyView() },
        leading: () -> Leading = { EmptyView() },
        trailing: () -> Trailing = { EmptyView() }
    ) {
        self.center = center()
        self.leading = leading()
        self.trailing = trailing()
    }

    var body: some View {
        ZStack {
            Color.srWhite
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
        .frame(height: 52)
    }
}


#Preview {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    appDelegate.rootView
}
