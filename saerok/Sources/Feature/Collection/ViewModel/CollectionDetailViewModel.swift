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

        enum LoadState {
            case loading
            case loaded
            case invalid
        }
        
        // MARK: State
        private(set) var loadState: LoadState = .loading
        private(set) var collection: Local.CollectionDetail
        private(set) var comments: [Local.CollectionComment] = []
        private(set) var likers: [Local.UserSummary] = []

        var suggestions: [Local.BirdSuggestion] = []
        var newSuggesting: Local.Bird?
        var selectedPreview: Local.BirdSuggestion?
        var selectedAdopting: Local.BirdSuggestion?
        var opinionFlow: OpinionFlow?
        var isGuest: Bool { appState[\.authStatus] == .guest }
        
        // MARK: Dependencies
        private let appState: Store<AppState>
        private let collectionInteractor: CollectionInteractor
        private let fieldGuideInteractor: FieldGuideInteractor

        // MARK: Init
        init(
            collectionID: Int,
            appState: Store<AppState>,
            collectionInteractor: CollectionInteractor,
            fieldGuideInteractor: FieldGuideInteractor
        ) {
            self.collectionID = collectionID
            self.appState = appState
            self.collectionInteractor = collectionInteractor
            self.fieldGuideInteractor = fieldGuideInteractor
            self.collection = .mockData[0]
        }
    

        // MARK: Side Effect
        func loadInitial() async {
            guard loadState != .loaded else { return }
            loadState = .loading

            await withTaskGroup(of: Void.self) { group in
                group.addTask { await self.fetchCollectionDetail() }
                group.addTask { await self.fetchComments() }
                group.addTask { await self.fetchSuggestions() }
                await group.waitForAll()
            }
            loadState = .loaded

            sendScreenViewEvent()
        }

        func fetchCollectionDetail() async {
            do {
                let result = try await collectionInteractor.fetchCollectionDetail(id: collectionID)
                collection = result
                loadState = .loaded
            } catch {
                loadState = .invalid
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
                collecionId: collectionID,
                commentId: id
            )
        }

        func toggleLike() async {
            do {
                let isLiked = try await collectionInteractor.toggleLike(collectionID)
                collection.likeToggle(isLiked)
            } catch {
            }
        }

        func suggestBird(birdID: Int) async {
            guard let flow = opinionFlow else { return }

            do {
                var result = try await collectionInteractor.suggestBird(collectionID, birdId: birdID)
                let bird = try await fieldGuideInteractor.loadBirdDetails(birdID: birdID)
                result.bird = bird

                suggestions.append(result)
                newSuggesting = nil

                Analytics.shared.log(
                    .opinionCreateSuccess(
                        .init(
                            recordId: "\(collectionID)",
                            opinionFlowId: flow.flowId,
                            birdId: "\(birdID)",
                            birdName: bird.name,
                            opinionId: "\(result.id)"
                        )
                    )
                )
            } catch {
                Analytics.shared.log(
                    .opinionCreateFailure(
                        .init(
                            recordId: "\(collectionID)",
                            opinionFlowId: flow.flowId,
                            birdId: "\(birdID)",
                            birdName: newSuggesting?.name ?? "",
                            errorCode: error.localizedDescription
                        )
                    )
                )
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
            Analytics.shared.log(.birdSearchResultClick(.init(recordId: "\(collectionID)", opinionFlowId: opinionFlow!.flowId, birdId: "\(bird.id)", birdName: bird.name)))
        }
        
        func startOpinionFlow() {
            if !collection.isMine {
                opinionFlow = OpinionFlow()
                Analytics.shared.log(.helpIdentifyClick(.init(recordId: "\(collectionID)", opinionFlowId: opinionFlow!.flowId)))
            }
        }
        
        func suggestingComplete() async {
            Analytics.shared.log(.opinionConfirmClick(.init(recordId: "\(collectionID)", opinionFlowId: opinionFlow!.flowId, birdId: "\(newSuggesting!.id)", birdName: newSuggesting!.name)))
            await suggestBird(birdID: newSuggesting?.id ?? 0)
        }
        
        func suggestingCancel() {
            Analytics.shared.log(.opinionConfirmNoClick(.init(recordId: "\(collectionID)", opinionFlowId: opinionFlow!.flowId, birdId: "\(newSuggesting!.id)", birdName: newSuggesting!.name)))
            newSuggesting = nil
        }
        
        func sendFindBirdLog() {
            Analytics.shared.log(.opinionAddClick(.init(recordId: "\(collectionID)", opinionFlowId: opinionFlow!.flowId)))
        }
        
        func reportCollection() async {
            try? await collectionInteractor.reportCollection(collectionID)
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
        
        // MARK: - Analytics
        private func sendScreenViewEvent() {
            guard collection.birdID == nil else { return }
            Analytics.shared.log(
                .unknownDetailView(.init(recordId: "\(collectionID)"))
            )
        }
        
    }
}
