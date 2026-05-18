//
//  AppStore.swift
//  saerok
//
//  Created by Hanseung on 5/18/26.
//

import Combine
import Foundation

enum AppAction {
    case enterGuestMode
    case requireAuthentication
    case finishSignIn(isRegistered: Bool)
    case restoreSession(AppState.AuthStatus)
    case syncCurrentUser(AppState.UserProfile)
    case clearCurrentUser
    case selectTab(TabbedItems)
    case requestFieldGuideScrollToTop
    case requestCollectionScrollToTop
    case openBoardDetail(Int)
    case openCollectionDetail(Int)
    case openMapCoordinate(MapView.Routing.Coordinate)
    case openFieldGuideBird(name: String)
    case refreshCollections
}

enum AppEvent: Equatable {
    case fieldGuideScrollToTop
    case collectionScrollToTop
    case boardDetailRequested(Int)
    case collectionDetailRequested(Int)
    case mapNavigationRequested(MapView.Routing.Coordinate)
    case fieldGuideBirdRequested(String)
    case collectionsRefreshRequested
}

final class AppStore {
    private let stateSubject: Store<AppState>
    private let eventSubject = PassthroughSubject<AppEvent, Never>()

    init(_ initialState: AppState = AppState()) {
        self.stateSubject = .init(initialState)
    }

    var appState: Store<AppState> {
        stateSubject
    }

    var state: AppState {
        stateSubject.value
    }

    var events: AnyPublisher<AppEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    subscript<T: Equatable>(keyPath: KeyPath<AppState, T>) -> T {
        state[keyPath: keyPath]
    }

    func updates<T: Equatable>(for keyPath: KeyPath<AppState, T>) -> AnyPublisher<T, Never> {
        stateSubject.updates(for: keyPath)
    }

    func send(_ action: AppAction) {
        switch action {
        case .enterGuestMode:
            updateState(\.currentUser, to: nil)
            updateState(\.authStatus, to: .guest)

        case .requireAuthentication:
            updateState(\.currentUser, to: nil)
            updateState(\.authStatus, to: .notDetermined)

        case .finishSignIn(let isRegistered):
            updateState(\.authStatus, to: .signedIn(isRegistered: isRegistered))

        case .restoreSession(let status):
            if status == .guest || status == .notDetermined {
                updateState(\.currentUser, to: nil)
            }
            updateState(\.authStatus, to: status)

        case .syncCurrentUser(let user):
            updateState(\.currentUser, to: user)

        case .clearCurrentUser:
            updateState(\.currentUser, to: nil)

        case .selectTab(let tab):
            updateState(\.routing.contentView.tabSelection, to: tab)

        case .requestFieldGuideScrollToTop:
            eventSubject.send(.fieldGuideScrollToTop)

        case .requestCollectionScrollToTop:
            eventSubject.send(.collectionScrollToTop)

        case .openBoardDetail(let id):
            eventSubject.send(.boardDetailRequested(id))

        case .openCollectionDetail(let id):
            eventSubject.send(.collectionDetailRequested(id))

        case .openMapCoordinate(let coordinate):
            eventSubject.send(.mapNavigationRequested(coordinate))

        case .openFieldGuideBird(let name):
            eventSubject.send(.fieldGuideBirdRequested(name))

        case .refreshCollections:
            eventSubject.send(.collectionsRefreshRequested)
        }
    }
}

private extension AppStore {
    func updateState<T: Equatable>(_ keyPath: WritableKeyPath<AppState, T>, to newValue: T) {
        stateSubject[keyPath] = newValue
    }
}
