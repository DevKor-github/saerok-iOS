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
    var authStatus: AuthStatus = .notDetermined
}

extension AppState {
    struct ViewRouting: Equatable {
        var contentView = ContentView.Routing(tabSelection: SRConstant.mainTab)
        var fieldGuideView = FieldGuideView.Routing()
        var collectionView = CollectionView.Routing()
        var addCollectionItemView = AddCollectionItemView.Routing()
    }
}

extension AppState {
    struct System: Equatable {
        var isSignedIn: Bool = false
    }
}

extension AppState {
    enum AuthStatus: Equatable {
        case notDetermined
        case guest
        case signedIn(isRegistered: Bool)
    }
}

func == (lhs: AppState, rhs: AppState) -> Bool {
    lhs.routing == rhs.routing &&
    lhs.system == rhs.system &&
    lhs.authStatus == rhs.authStatus
}
