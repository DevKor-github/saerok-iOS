//
//  CollectionDetailViewModel.swift
//  saerok
//
//  Created by HanSeung on 4/12/25.
//

import Foundation

extension CollectionDetailView {
    @Observable
    final class ViewModel {
        
        let collectionID: Int

        // MARK: State
        private(set) var loadState: LoadState<Void> = .loading
        private(set) var collection: Local.CollectionDetail
        private(set) var comments: [Local.CollectionComment] = []
        private(set) var likers: [Local.UserSummary] = []

        var suggestions: [Local.BirdSuggestion] = []
        var newSuggesting: Local.Bird?
        var selectedPreview: Local.BirdSuggestion?
        var selectedAdopting: Local.BirdSuggestion?
        var isGuest: Bool { appState[\.authStatus] == .guest }
        
        // MARK: Analytics
        private(set) var detailFlow: DetailViewFlow?
        
        // MARK: Dependencies
        private let appState: Store<AppState>
        private let collectionInteractor: CollectionInteractor
        private let fieldGuideInteractor: FieldGuideInteractor
        private let userInteractor: UserInteractor

        // MARK: Init
        init(
            collectionID: Int,
            entrySource: EntrySource = .unknown,
            screen: Screen = .unknown,
            appState: Store<AppState>,
            collectionInteractor: CollectionInteractor,
            fieldGuideInteractor: FieldGuideInteractor,
            userInteractor: UserInteractor
        ) {
            self.collectionID = collectionID
            self.appState = appState
            self.collectionInteractor = collectionInteractor
            self.fieldGuideInteractor = fieldGuideInteractor
            self.userInteractor = userInteractor
            self.collection = .mockData[0]
            
            // DetailViewFlow는 collection 데이터 로드 후 초기화
            self.detailFlow = DetailViewFlow(
                recordId: "\(collectionID)",
                entrySource: entrySource,
                screen: screen,
                isOwnRecord: false, // 초기값, loadInitial에서 업데이트
                listLikeCount: 0,
                listCommentCount: 0
            )
        }
    

        // MARK: Side Effect
        func loadInitial() async {
            guard loadState.value == nil else { return }
            loadState = .loading

            await withTaskGroup(of: Void.self) { group in
                group.addTask { await self.fetchCollectionDetail() }
                group.addTask { await self.fetchComments() }
                group.addTask { await self.fetchSuggestions() }
                await group.waitForAll()
            }
            loadState = .success(())
            
            // 데이터 로드 완료 후 DetailViewFlow 업데이트
            if let flow = detailFlow {
                detailFlow = DetailViewFlow(
                    recordId: "\(collectionID)",
                    entrySource: flow.entrySource,
                    screen: flow.screen,
                    isOwnRecord: collection.isMine,
                    listLikeCount: collection.likeCount,
                    listCommentCount: collection.commentCount
                )
                
                // saerok_detail_view 이벤트
                if let detailFlow = detailFlow {
                    Analytics.shared.logSaerokDetailView(flow: detailFlow)
                }
            }
        }

        func fetchCollectionDetail() async {
            do {
                let result = try await collectionInteractor.fetchCollectionDetail(id: collectionID)
                collection = result
                loadState = .success(())
            } catch {
                loadState = .failure(error)
            }
        }

        func fetchComments() async {
            do {
                comments = try await collectionInteractor.fetchComments(collectionID)
            } catch {
            }
        }

        func fetchSuggestions() async {
            do {
                let result = try await collectionInteractor.fetchBirdSuggestions(collectionID)
                suggestions = result
                selectedPreview = result.first
            } catch {
                suggestions = []
            }
        }

        func postComment(text: String, parentId: Int?) async {
            do {
                try await collectionInteractor.createComments(id: collectionID, parentId: parentId, text)
                comments = try await collectionInteractor.fetchComments(collectionID)
                collection.commentCount += 1
            } catch {
                // 실패해도 UI 유지
            }
        }

        func deleteComment(id: Int) async {
            do {
                try await collectionInteractor.deleteComment(collectionId: collectionID, commentId: id)
                comments = try await collectionInteractor.fetchComments(collectionID)
                collection.commentCount -= 1
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
                collection.likeToggle(isLiked)
                
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
            try? await userInteractor.blockUser(userId: collection.user.id)
        }

        func blockUser(userId: Int) async {
            try? await userInteractor.blockUser(userId: userId)
        }
        
        func navigateToMap() {
            appState[\.routing.contentView.tabSelection] = .map
            appState[\.routing.mapView.navigation] = .init(
                latitude: collection.coordinate.latitude,
                longitude: collection.coordinate.longitude
            )
        }
        
        func navigateToFieldGuide() {
            appState[\.routing.contentView.tabSelection] = .fieldGuide
            appState[\.routing.fieldGuideView.birdName] = collection.birdName
        }
        
        func refreshLikers() async throws {
            likers = try await collectionInteractor.fetchLikeUsers(collectionID)
        }
    }
}
