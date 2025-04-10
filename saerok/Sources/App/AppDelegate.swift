//
//  AppDelegate.swift
//  saerok
//
//  Created by HanSeung on 4/8/25.
//

import SwiftUICore
import UIKit

@MainActor
final class AppDelegate: UIResponder, UIApplicationDelegate {
    private lazy var environment = AppEnvironment.bootstrap()
    
    var rootView: some View {
        environment.rootView
    }
}
