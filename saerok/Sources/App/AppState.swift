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

    /// 푸시 알림 등으로 요청된, 아직 처리되지 않은 딥링크.
    ///
    /// 일회성 이벤트(`PassthroughSubject`)는 콜드 스타트 시 구독자(탭 ViewModel)가
    /// 생성되기 전에 발행되면 유실된다. `CurrentValueSubject`인 상태로 보관하면
    /// 늦게 구독하는 ViewModel도 현재값을 즉시 받아 딥링크를 처리할 수 있다.
    /// 처리한 ViewModel은 `clearPendingDeepLink`로 소비해 중복 내비게이션을 막는다.
    var pendingDeepLink: DeepLink? = nil
}

extension AppState {
    enum DeepLink: Equatable {
        case boardDetail(Int)
        case freeBoardPost(Int)
        case collectionDetail(Int)
        case notificationView
    }
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
    lhs.currentUser == rhs.currentUser &&
    lhs.pendingDeepLink == rhs.pendingDeepLink
}
