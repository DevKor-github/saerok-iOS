//
//  UserManager.swift
//  saerok
//
//  Created by HanSeung on 6/14/25.
//

import Foundation
import SwiftData

@Observable
final class UserManager {
    static let shared = UserManager()

    private(set) var user: User? = nil
    private var interactor: UserInteractor?

    func configure(with interactor: UserInteractor) {
        self.interactor = interactor
        loadUser()
    }

    func refreshUser() async {
        guard let user = try? await interactor?.getUser() else { return }
        syncUser(from: user)
    }
    
    func syncUser(from user: User) {
        self.user = user
    }
    
    func updateNickname(to newNickname: String) async throws {
        try await interactor?.updateNickname(newNickname)
        self.user?.nickname = newNickname
    }
    
    func deleteUser() async throws {
        try await interactor?.deleteUser()
        self.user = nil
    }

    private func loadUser() {
        Task {
            do {
                self.user = try await interactor?.getUser()
            } catch { }
        }
    }
}
