//
//  AppState.swift
//  saerok
//
//  Created by HanSeung on 4/8/25.
//

import Foundation

struct AppState: Equatable {
    var routing = ViewRouting()
    var authStatus: AuthStatus = .notDetermined
    var currentUser: UserProfile? = nil
}

extension AppState {
    struct ViewRouting: Equatable {
        var contentView = ContentView.Routing(tabSelection: SRConstant.mainTab)
    }
}

extension AppState {
    enum AuthStatus: Equatable {
        case notDetermined
        case guest
        case signedIn(isRegistered: Bool)
    }
}

extension AppState {
    struct UserProfile: Equatable {
        var nickname: String
        var email: String
        var imageURL: String?
        var joinedDate: Date

        init(_ user: User) {
            self.nickname = user.nickname
            self.email = user.email
            self.imageURL = user.imageURL
            self.joinedDate = user.joinedDate
        }
    }
}

func == (lhs: AppState, rhs: AppState) -> Bool {
    lhs.routing == rhs.routing &&
    lhs.authStatus == rhs.authStatus &&
    lhs.currentUser == rhs.currentUser
}
