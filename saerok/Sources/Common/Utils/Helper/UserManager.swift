//
//  UserManager.swift
//  saerok
//
//  Created by HanSeung on 6/14/25.
//


import Foundation
import SwiftData

@MainActor
final class UserManager: ObservableObject {
    static let shared = UserManager()
    
    @Published private(set) var user: User? = nil
    private var context: ModelContext?

    func configure(with context: ModelContext) {
        self.context = context
        loadUser()
    }

    func syncUser(from dto: DTO.MeResponse) {
        guard let context else { return }

        if let existing = user {
            context.delete(existing)
        }

        let newUser = User(dto: dto)
        context.insert(newUser)
        self.user = newUser
    }
    
    func updateNickname(to newNickname: String, networkService: SRNetworkService) async throws {
        let updatedUser: DTO.MeResponse = try await networkService.performSRRequest(.updateMe(nickname: newNickname))

        guard let user = fetchUser() else { return }

        user.nickname = updatedUser.nickname

        try context?.save()
        self.user = user
    }
    
    func deleteUser() {
        guard let user = fetchUser() else { return }
        
        context?.delete(user)
        self.user = nil
    }

    private func loadUser() {
        guard let context else { return }
        do {
            let users = try context.fetch(FetchDescriptor<User>())
            self.user = users.first
        } catch {
            print("❌ User 로드 실패: \(error)")
        }
    }
    
    private func fetchUser() -> User? {
        guard let context else { return nil }
        do {
            return try context.fetch(FetchDescriptor<User>()).first
        } catch {
            print("❌ User fetch 실패: \(error)")
            return nil
        }
    }
}
