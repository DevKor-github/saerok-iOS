//
//  UserSummaryViewModel.swift
//  saerok
//
//  Created by HanSeung on 10/10/25.
//

import Foundation

extension UserSummaryView {
    @Observable
    final class ViewModel: ObservableObject {
        private let userID: Int
        private(set) var summaryState: LoadState<Local.UserProfileSummary> = .notRequested
        
        private let interactor: UserInteractor
        private let cancelBag: CancelBag
        
        init(userID: Int, interactor: UserInteractor) {
            self.userID = userID
            self.interactor = interactor
            self.cancelBag = .init()
        }
        
        func loadSummary() async {
            if case .notRequested = summaryState {
                summaryState = await summaryState.load {
                    try await interactor.fetchUserSummary(userID: userID)
                }
            }
        }
    }
}
