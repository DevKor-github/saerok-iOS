//
//  CommunityViewModel.swift
//  saerok
//
//  Created by HanSeung on 9/15/25.
//

import Foundation
import Combine

extension CommunityView {
    @Observable
    final class ViewModel {
        
        // MARK: State
        private(set) var searchMainItems: Local.CommunitySearchMainItems = .init()
        private(set) var mainItems: Local.CommunityMainItems = .init()
        private(set) var loadState: LoadState<Void> = .notRequested
        var text: String = ""
        var searchCase: CommunitySearchCase = .all
        
        var mode: SearchInputBar.Mode = .idle
        var isModeIdle: Bool { mode == .idle }
        private(set) var isGuestMode: Bool = true
        private(set) var currentUser: AppState.UserProfile?

        // MARK: Dependencies
        private var appStore: AppStore
        private let interactor: CommunityInteractor

        private var searchDebounceTask: Task<Void, Never>?
        private var cancelBag: CancelBag

        init(appStore: AppStore, interactor: CommunityInteractor) {
            self.appStore = appStore
            self.interactor = interactor
            self.cancelBag = .init()
            self.isGuestMode = appStore[\.authStatus] == .guest
            self.currentUser = appStore[\.currentUser]
            cancelBag.collect {
                appStore
                    .updates(for: \.authStatus)
                    .map { $0 == .guest }
                    .removeDuplicates()
                    .weakSink(on: self) { viewModel, isGuest in
                        viewModel.isGuestMode = isGuest
                    }

                appStore
                    .updates(for: \.currentUser)
                    .weakSink(on: self) { viewModel, user in
                        viewModel.currentUser = user
                    }

                appStore.events
                    .compactMap { event -> Int? in
                        guard case .freeBoardPostDeleted(let postId) = event else { return nil }
                        return postId
                    }
                    .weakSink(on: self) { viewModel, postId in
                        viewModel.removeFreeBoardPost(postId)
                    }
            }
        }
        
        var currentUserNickname: String { currentUser?.nickname ?? "" }
        var currentUserProfileImageUrl: String? { currentUser?.imageURL }

        func createFreeboardPost(content: String) async throws {
            _ = try await interactor.createFreeboardPost(content: content)
        }
        
        func loadPosts() async {
            if case .notRequested = loadState {
                loadState = await loadState.load {
                    self.mainItems = try await interactor.fetchMain()
                }
            }
        }
        
        func refreshPosts() async {
            do {
                self.mainItems = try await interactor.fetchMain()
            } catch {
                loadState = .failure(error)
            }
        }
        
        func updateSearchText(_ text: String) {
            self.text = text
            
            if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                self.searchMainItems = .init(collections: [], users: [], collectionsCount: 0, usersCount: 0)
                self.mode = .searching
                return
            }
            
            searchDebounceTask = .debounce(delay: 400_000_000, task: searchDebounceTask) {
                await self.performSearch(text, for: self.searchCase)
            }
        }
        
        func perfomrSearch() {
            Task {
                await performSearch(text, for: searchCase)
            }
        }
        
        func initLoginStatus() {
            appStore.send(.requireAuthentication)
        }
        
        private func performSearch(_ text: String, for searchCase: CommunitySearchCase) async {
            let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !query.isEmpty else {
                self.searchMainItems = .init()
                return
            }
            
            do {
                searchMainItems = try await interactor.search(text, searchCase: searchCase)
                self.mode = .resultShown
            } catch {
                self.searchMainItems = .init()
                self.mode = .searching
            }
        }
        
        private func scheduleSearch() {
            guard mode != .idle else { return }
            
            searchDebounceTask?.cancel()
            let text = self.text.trimmingCharacters(in: .whitespacesAndNewlines)
            let searchCase = self.searchCase
            
            searchDebounceTask = Task { [weak self] in
                try? await Task.sleep(for: .milliseconds(600))
                guard !Task.isCancelled else { return }
                
                if text.isEmpty {
                    self?.searchMainItems = .init()
                    self?.mode = .searching
                } else {
                    await self?.performSearch(text, for: searchCase)
                }
            }
        }

        private func removeFreeBoardPost(_ postId: Int) {
            mainItems = .init(
                pendingCollections: mainItems.pendingCollections,
                recentCollections: mainItems.recentCollections,
                popularCollections: mainItems.popularCollections,
                recentFreeBoardPosts: mainItems.recentFreeBoardPosts.filter { $0.id != postId }
            )
        }
    }
}
