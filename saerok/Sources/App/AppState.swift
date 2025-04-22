//
//  AppState.swift
//  saerok
//
//  Created by HanSeung on 4/8/25.
//


import SwiftUI
import Combine

struct AppState: Equatable {
    var routing = ViewRouting()
    var system = System()
}

extension AppState {
    struct ViewRouting: Equatable {
        var contentView = ContentView.Routing(tabSelection: SRConstant.mainTab)
        var fieldGuideView = FieldGuideView.Routing()
        var collectionView = CollectionView.Routing()
    }
}

extension AppState {
    struct System: Equatable { }
}

func == (lhs: AppState, rhs: AppState) -> Bool {
    return lhs.routing == rhs.routing && lhs.system == rhs.system
}
