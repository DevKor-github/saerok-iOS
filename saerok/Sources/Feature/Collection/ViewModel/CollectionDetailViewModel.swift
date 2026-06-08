//
//  CollectionDetailViewModel.swift
//  saerok
//
//  Created by HanSeung on 4/12/25.
//

import Foundation
import Combine

extension CollectionDetailView {
    @Observable
    final class ViewModel {
        
        let collectionID: Int

        // MARK: State
        private(set) var loadState: LoadState<Void> = .loading
        private(set) var collection: Local.CollectionDetail?
        private(set) var comments: [Local.CollectionComment] = []
        private(set) var likers: [Local.UserSummary] = []

        var suggestions: [Local.BirdSuggestion] = []
        var newSuggesting: Local.Bird?
        var selectedPreview: Local.BirdSuggestion?
        var selectedAdopting: Local.BirdSuggestion?
        private(set) var isGuest: Bool
        
        // MARK: Analytics
        private(set) var detailFlow: DetailViewFlow?
        
        // MARK: Dependencies
        private let appStore: AppStore
        private let collectionInteractor: CollectionInteractor
        private let fieldGuideInteractor: FieldGuideInteractor
        private let userInteractor: UserInteractor
        private let cancelBag = CancelBag()

        // MARK: Init
        init(
            collectionID: Int,
            entrySource: EntrySource = .unknown,
            screen: Screen = .unknown,
            appStore: AppStore,
            collectionInteractor: CollectionInteractor,
            fieldGuideInteractor: FieldGuideInteractor,
            userInteractor: UserInteractor
        ) {
            self.collectionID = collectionID
            self.appStore = appStore
            self.collectionInteractor = collectionInteractor
            self.fieldGuideInteractor = fieldGuideInteractor
            self.userInteractor = userInteractor
            self.isGuest = appStore[\.authStatus] == .guest
            
            // DetailViewFlow는 collection 데이터 로드 후 초기화
            self.detailFlow = DetailViewFlow(
                recordId: "\(collectionID)",
                entrySource: entrySource,
                screen: screen,
                isOwnRecord: false, // 초기값, loadInitial에서 업데이트
                listLikeCount: 0,
                listCommentCount: 0
            )

            appStore
                .updates(for: \.authStatus)
                .map { $0 == .guest }
                .removeDuplicates()
                .weakSink(on: self) { viewModel, isGuest in
                    viewModel.isGuest = isGuest
                }
                .store(in: cancelBag)
        }
    

        // MARK: Side Effect
        func loadInitial() async {
            guard loadState.value == nil else { return }
            await MainActor.run { loadState = .loading }

            await withTaskGroup(of: Void.self) { group in
                group.addTask { await self.fetchCollectionDetail() }
                group.addTask { await self.fetchComments() }
                group.addTask { await self.fetchSuggestions() }
                await group.waitForAll()
            }

            // withTaskGroup 자식 태스크는 메인 밖에서 실행되므로
            // @Observable 상태 변경은 반드시 메인에서 수행해야 SwiftUI가 관찰한다.
            await MainActor.run {
                loadState = .success(())

                // 데이터 로드 완료 후 DetailViewFlow 업데이트
                if let flow = detailFlow {
                    detailFlow = DetailViewFlow(
                        recordId: "\(collectionID)",
                        entrySource: flow.entrySource,
                        screen: flow.screen,
                        isOwnRecord: collection?.isMine ?? false,
                        listLikeCount: collection?.likeCount ?? 0,
                        listCommentCount: collection?.commentCount ?? 0
                    )

                    // saerok_detail_view 이벤트
                    if let detailFlow = detailFlow {
                        Analytics.shared.logSaerokDetailView(flow: detailFlow)
                    }
                }
            }
        }

        func fetchCollectionDetail() async {
            do {
                let result = try await collectionInteractor.fetchCollectionDetail(id: collectionID)
                await MainActor.run {
                    collection = result
                    loadState = .success(())
                }
            } catch {
                await MainActor.run { loadState = .failure(error) }
            }
        }

        func fetchComments() async {
            do {
                let result = try await collectionInteractor.fetchComments(collectionID)
                await MainActor.run { comments = result }
            } catch {
            }
        }

        func fetchSuggestions() async {
            do {
                let result = try await collectionInteractor.fetchBirdSuggestions(collectionID)
                await MainActor.run {
                    suggestions = result
                    selectedPreview = result.first
                }
            } catch {
                await MainActor.run { suggestions = [] }
            }
        }

        func postComment(text: String, parentId: Int?) async {
            do {
                try await collectionInteractor.createComments(id: collectionID, parentId: parentId, text)
                comments = try await collectionInteractor.fetchComments(collectionID)
                collection?.commentCount += 1
            } catch {
                // 실패해도 UI 유지
            }
        }

        func deleteComment(id: Int) async {
            do {
                try await collectionInteractor.deleteComment(collectionId: collectionID, commentId: id)
                // 최상위 댓글 제거
                comments.removeAll { $0.id == id }
                // 대댓글 제거
                comments = comments.map { parent in
                    guard let replies = parent.replies else { return parent }
                    let filtered = replies.filter { $0.id != id }
                    return Local.CollectionComment(
                        id: parent.id, user: parent.user, content: parent.content,
                        likeCount: parent.likeCount, isLiked: parent.isLiked, isMine: parent.isMine,
                        createdAt: parent.createdAt, parentId: parent.parentId,
                        replies: filtered, isInteractive: parent.isInteractive,
                        isMyCollection: parent.isMyCollection
                    )
                }
                collection?.commentCount -= 1
            } catch {
            }
        }
        
        func reportComment(id: Int) async {
            try? await collectionInteractor.reportComment(
                collectionId: collectionID,
                commentId: id
            )
        }

        func toggleLike() async {
            do {
                let isLiked = try await collectionInteractor.toggleLike(collectionID)
                collection?.likeToggle(isLiked)
                
                // saerok_like_toggle 이벤트
                if let flow = detailFlow {
                    Analytics.shared.logSaerokLikeToggle(
                        flow: flow,
                        likeState: isLiked ? .on : .off
                    )
                }
            } catch {
            }
        }

        func suggestBird(birdID: Int) async {
            do {
                var result = try await collectionInteractor.suggestBird(collectionID, birdId: birdID)
                let bird = try await fieldGuideInteractor.loadBirdDetails(birdID: birdID)
                result.bird = bird

                suggestions.append(result)
                newSuggesting = nil
            } catch {
    
            }
        }

        func adoptBird() async {
            do {
                try await collectionInteractor.adoptSuggestion(collectionID, birdId: selectedAdopting?.bird.id ?? 0)
                await fetchCollectionDetail()
            } catch {
            }
        }
        
        func selectSuggestingBird(_ bird: Local.Bird) {
            newSuggesting = bird
        }
        
        func suggestingComplete() async {
            await suggestBird(birdID: newSuggesting?.id ?? 0)
        }
        
        func suggestingCancel() {
            newSuggesting = nil
        }

        
        func reportCollection() async {
            try? await collectionInteractor.reportCollection(collectionID)
        }

        func blockCollectionUser() async {
            guard let collection else { return }
            try? await userInteractor.blockUser(userId: collection.user.id)
        }

        func blockUser(userId: Int) async {
            try? await userInteractor.blockUser(userId: userId)
        }
        
        func navigateToMap() {
            guard let collection, let coordinate = collection.coordinate else { return }
            appStore.send(.selectTab(.map))
            appStore.send(.openMapCoordinate(.init(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            )))
        }
        
        func navigateToFieldGuide() {
            guard let birdName = collection?.birdName else { return }
            appStore.send(.selectTab(.fieldGuide))
            appStore.send(.openFieldGuideBird(name: birdName))
        }
        
        func refreshLikers() async throws {
            likers = try await collectionInteractor.fetchLikeUsers(collectionID)
        }
    }
}
