//
//  CollectionDetailView.swift
//  saerok
//
//  Created by HanSeung on 4/12/25.
//

import SwiftUI

enum CollectionDetailRoute: AppRoute {
    case edit
    case bird(_ id: Int)
    case other(_ id: Int)
}

struct CollectionDetailView: View {
    typealias Route = CollectionDetailRoute
    private let variant = ABTestManager.shared.interactionZoneVariant

    struct CollectionUIState: Equatable {
        var showPopup: Bool = false
        var showSuggestPopup: Bool = false
        var showAdoptPopup: Bool = false
        //사용자 차단
        var showBlockUserPopup: Bool = false
        var showCommentSheet: Bool = false
        var showSuggestionSheet: Bool = false
        var showFindBird: Bool = false
        var showShareSheet: Bool = false
        var showLikerSheet: Bool = false
        var showFullImage = false
        var text: String = ""
        var selectedComment: Local.CollectionComment?
        var collectionImage: UIImage?
    }
    
    // MARK:  View State
    @State var viewModel: ViewModel
    @State private var uiState = CollectionUIState()
    @State private var error: Error? = nil
    @FocusState private var isFocused
    @State private var keyboard = KeyboardObserver()
        
    // MARK: Environment
    @EnvironmentObject private var coordinator: AppCoordinator
    
    // MARK: Init
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: Body
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            content
            
            CollectionPopupLayer(
                showPopup: $uiState.showPopup,
                showSuggestPopup: $uiState.showSuggestPopup,
                showAdoptPopup: $uiState.showAdoptPopup,
                showBlockPopup: $uiState.showBlockUserPopup,
                alertConfig: uiState.showPopup ? postReportPopupConfig : nil,
                adoptConfig: uiState.showAdoptPopup ? adoptPopupConfig : nil,
                suggestConfig: uiState.showSuggestPopup ? suggestPopupConfig : nil,
                blockUserConfig: uiState.showBlockUserPopup ? blockUserPopupConfig : nil
            )
            
            if !(uiState.showCommentSheet || uiState.showSuggestionSheet || uiState.showFullImage) {
                interactionZone
            }

            shareSheetSection

            if !(uiState.showCommentSheet || uiState.showSuggestionSheet || uiState.showFullImage) {
                shareButton
            }
            
            if viewModel.loadState.inError {
                InvalidAlertView(action: { coordinator.pop() })
                    .ignoresSafeArea(.all)
            }
        }
        .regainSwipeBack()
        .task {
            // saerok_detail_tap 이벤트 (화면 진입)
            if let flow = viewModel.detailFlow {
                Analytics.shared.logSaerokDetailTap(flow: flow)
            }
            
            await viewModel.loadInitial()
            downloadImage(from: viewModel.collection?.imageURL ?? "")
        }
        .onDisappear {
            // saerok_detail_exit 이벤트 (화면 이탈)
            if let flow = viewModel.detailFlow {
                let exitReason: ExitReason = coordinator.path.isEmpty ? .backButton : .navigationTap
                Analytics.shared.logSaerokDetailExit(flow: flow, exitReason: exitReason)
            }
        }
        .navigationDestination(for: Route.self) { route in
            routeView(for: route)
        }
        .fullScreenCover(isPresented: $uiState.showFindBird) {
            CollectionSearchView(
                onSelect: { bird in
                    viewModel.selectSuggestingBird(bird)
                    uiState.showFindBird = false
                }
            )
        }
    }
}

// MARK: - Navigation
private extension CollectionDetailView {
    @ViewBuilder
    func routeView(for route: Route) -> some View {
        switch route {
        case .edit:
            if let collection = viewModel.collection {
                CollectionFormView(viewModel: coordinator.makeCollectionFormViewModel(mode: .edit(collection)))
            }
        case .bird(let id):
            BirdDetailView(viewModel: coordinator.makeBirdDetailViewModel(birdID: id))
        case .other(let id):
            UserSummaryView(viewModel: coordinator.makeUserSummaryViewModel(id))
        }
    }
}

// MARK: - Content
private extension CollectionDetailView {
    var content: some View {
        ZStack(alignment: .top) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .center, spacing: 0) {
                    Color.clear
                        .frame(height: 57)
                    
                    imageSection
                        .shimmerIfLoading(viewModel.loadState.value == nil)
                    
                    descriptionSection
                        .padding(.horizontal, SRDesignConstant.defaultPadding)
                        .offset(y: -20)
                    
                    Color.clear
                        .frame(height: 160)
                }
                
                Spacer()
            }
            navigationBar
        }
        .background(Color.srLightGray)
        .bottomSheet(isShowing: $uiState.showCommentSheet, isFocused: _isFocused, keyboard: keyboard) {
            CollectionCommentSheet(
                viewModel: viewModel,
                collectionId: viewModel.collectionID,
                collectionUserId: viewModel.collection?.user.id ?? 0,
                isMyCollection: viewModel.collection?.isMine ?? false,
                comments: viewModel.comments,
                selectedComment: $uiState.selectedComment,
                onTap: { userId in coordinator.push(Route.other(userId)) },
                onDelete: viewModel.deleteComment,
                onDismiss: { uiState.showCommentSheet.toggle() },
            )
        }
        .sheet(isPresented: $uiState.showLikerSheet) {
            CollectionLikerSheet(
                viewModel: coordinator.makeCollectionLikerSheetViewModel(viewModel.collectionID),
                onDismiss: { uiState.showLikerSheet.toggle() }
            )
        }
        .onTapGesture {
            isFocused = false
            uiState.selectedComment = nil
        }
        .commentInputOverlay(isPresented: $uiState.showCommentSheet) {
            CollectionCommentInputBar(
                text: $uiState.text,
                selectedNickname: uiState.selectedComment?.user.nickname,
                nickname: viewModel.collection?.user.nickname ?? "",
                onSubmit: {
                    await viewModel.postComment(
                        text: uiState.text,
                        parentId: uiState.selectedComment?.id
                    )
                    uiState.selectedComment = nil
                },
                isOnSheet: true,
                isFocused: _isFocused,
                keyboard: keyboard,
                isGuest: viewModel.isGuest
            )
        }
        .bottomSheet(isShowing: $uiState.showSuggestionSheet, keyboard: keyboard, isExtendable: false) {
            SuggestionSheet(
                isMine: viewModel.collection?.isMine ?? false,
                collectionID: viewModel.collectionID,
                nickname: viewModel.collection?.user.nickname ?? "",
                suggestions: $viewModel.suggestions,
                selectedBird: $viewModel.newSuggesting,
                selectedPreview: $viewModel.selectedPreview,
                selectedAdopting: $viewModel.selectedAdopting,
                showSuggestPopup: $uiState.showSuggestPopup,
                showAdoptPopup: $uiState.showAdoptPopup,
                onDismiss: { uiState.showSuggestionSheet.toggle() },
                onFindBird: {
                    uiState.showFindBird = true
                }
            )
        }
        .topOverlay(observed: viewModel.selectedPreview?.bird.id) { birdPreview }
        .ignoresSafeArea(.all)
        .fullImageOverlay(
            isPresented: $uiState.showFullImage,
            image: uiState.collectionImage,
        )
        .onChange(of: uiState.showCommentSheet) { _, new in
            if new == false {
                uiState.selectedComment = nil
                
                // saerok_comment_close 이벤트
                if let flow = viewModel.detailFlow {
                    Analytics.shared.logSaerokCommentClose(flow: flow)
                }
            } else {
                // saerok_comment_open 이벤트
                if let flow = viewModel.detailFlow {
                    let commentLoaded = !viewModel.comments.isEmpty
                    Analytics.shared.logSaerokCommentOpen(flow: flow, commentLoaded: commentLoaded)
                }
            }
        }
    }
    
    var navigationBar: some View {
        NavigationBar(
            leading: { leadingButton },
            backgroundColor: .clear
        )
        .padding(.top, 60)
    }
    
    @ViewBuilder
    var leadingButton: some View {
        if !coordinator.path.isEmpty {
            Button { coordinator.pop() } label: {
                Image.SRIconSet.chevronLeft
                    .frame(.default)
            }
            .srStyled(.iconButton)
        }
    }
    
    @ViewBuilder
    var imageSection: some View {
        let image = ReactiveAsyncImageWithMetadata(
            url: viewModel.collection?.imageURL ?? "",
            scale: .medium,
            downsampling: true,
            isCachingEnabled: true
        )
        
        image
            .scaledToFill()
            .cornerRadius(35)
            .padding(.horizontal, 9)
            .frame(width: UIScreen.main.bounds.width)
            .clipped()
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.35)) {
                    uiState.showFullImage = true
                }
            }
    }
    
    @ViewBuilder
    var descriptionSection: some View {
        if let collection = viewModel.collection {
        CollectionDescriptionSection(
            collection: collection,
        ) { action in
            switch action {
            case .reportTap:
                uiState.showPopup.toggle()
                
            // 사용자 차단
            case .blockUserTap:
                uiState.showBlockUserPopup.toggle()
                
            case .suggestTap:
                uiState.showSuggestionSheet.toggle()
                
            case .navigateToFieldGuide:
                viewModel.navigateToFieldGuide()
                
            case .navigateToMap:
                viewModel.navigateToMap()
                
            case .navigateToOther(let userId):
                coordinator.push(Route.other(userId))
            }
        }
        }
    }
    
    @ViewBuilder
    private var interactionZone: some View {
        if let collection = viewModel.collection {
            InteractionZone(
                variant: variant,
                collection: collection,
                onLikeTap: {
                    Task {
                        HapticManager.shared.trigger(.light)
                        await viewModel.toggleLike()
                    }
                },
                onLikeCountTap: { uiState.showLikerSheet.toggle() },
                onCommentTap: {uiState.showCommentSheet.toggle() }
            )
            .frame(maxWidth: .infinity, alignment: variant == .a ? .bottom : .bottomTrailing)
        }
    }
    
    @ViewBuilder
    var shareSheetSection: some View {
        if let image = uiState.collectionImage,
           uiState.showShareSheet,
           let collection = viewModel.collection
        {
            CollectionShareView(
                collection: collection,
                isPresented: $uiState.showShareSheet,
                image: image
            )
        }
    }
    
    @ViewBuilder
    var shareButton: some View {
        if viewModel.collection?.isMine == true {
            Button(action: { uiState.showShareSheet.toggle() }) {
                Image.SRIconSet.airplane
                    .frame(.floatingButton)
                    .padding(.trailing, 24)
                    .padding(.bottom, 6)
            }
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    var birdPreview: some View {
        if let suggestion = viewModel.selectedPreview,
           uiState.showSuggestionSheet
        {
            ZStack(alignment: .bottomTrailing) {
                AsyncImage(
                    url: suggestion.bird.imageURL!,
                    size: CGSize(width: 220, height: 227),
                    scale: .medium,
                    downsampling: true
                )
                .clipped()
                .frame(width: 220, height: 227)
                .cornerRadius(23)
                .padding(.top, 66)
                
                if !coordinator.path.isEmpty {
                    Button {
                        coordinator.push(Route.bird(suggestion.bird.id))
                    } label: {
                        Image.SRIconSet.chevronRight
                            .frame(.default)
                    }
                    .srStyled(.iconButton)
                    .padding(4)
                }
            }
        }
    }
            
    func navigateToOther(_ userId: Int) {
        coordinator.push(Route.other(userId))
    }
    
    func downloadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data, let image = UIImage(data: data) else { return }
            Task { @MainActor in
                uiState.collectionImage = image
                
                // 이미지 로드 완료 표시
                viewModel.detailFlow?.markImageLoaded()
            }
        }.resume()
    }
}

// MARK: - Popup Configs
private extension CollectionDetailView {
    var postReportPopupConfig: PopupConfig {
        PopupConfig(
            title: "게시물을 신고하시겠어요?",
            message: "커뮤니티 가이드에 따라\n신고 사유에 해당하는지 검토 후 처리돼요.",
            buttons: .double(
                .init(title: "신고하기", style: .delete, action: {
                    Task { await viewModel.reportCollection(); uiState.showPopup = false }
                }),
                .init(title: "돌아가기", style: .confirm, action: { uiState.showPopup = false })
            )
        )
    }

    var suggestPopupConfig: PopupConfig {
        PopupConfig(
            title: "'\(viewModel.newSuggesting?.name ?? "딱새")'가 맞나요?",
            message: "정확하지 않은 이름의 제안은 사용자들에게\n혼란을 일으킬 수 있어요.",
            buttons: .double(
                .init(title: "취소", style: .bordered, action: {
                    uiState.showSuggestPopup = false; viewModel.suggestingCancel()
                }),
                .init(title: "동정돕기", style: .confirm, action: {
                    Task { await viewModel.suggestingComplete(); uiState.showSuggestPopup = false }
                })
            )
        )
    }

    var adoptPopupConfig: PopupConfig {
        PopupConfig(
            title: "'\(viewModel.selectedAdopting?.bird.name ?? "딱새")'로 채택하시겠어요?",
            message: "채택된 이후 동정 돕기 창은 사라지며,\n다시 이름 모를 새로 전환하면\n보이게 할 수 있어요.",
            buttons: .double(
                .init(title: "취소", style: .bordered, action: { uiState.showAdoptPopup = false }),
                .init(title: "채택하기", style: .confirm, action: {
                    Task { await viewModel.adoptBird(); uiState.showAdoptPopup = false }
                })
            )
        )
    }

    var blockUserPopupConfig: PopupConfig {
        PopupConfig(
            title: "이 사용자를 차단할까요?",
            message: "차단한 사용자의 게시물과 댓글을\n더 이상 볼 수 없어요.",
            buttons: .double(
                .init(title: "차단하기", style: .delete, action: {
                    Task {
                        await viewModel.blockCollectionUser()
                        uiState.showBlockUserPopup = false
                        coordinator.pop()
                    }
                }),
                .init(title: "취소", style: .confirm, action: { uiState.showBlockUserPopup = false })
            )
        )
    }
}

private extension View {
    func topOverlay<Overlay: View, T: Hashable>(
        observed value: T,
        alignment: Alignment = .top,
        @ViewBuilder overlay: @escaping () -> Overlay
    ) -> some View {
        ZStack(alignment: alignment) {
            self
            overlay()
        }
        .id(value)
    }
    
    func shimmerIfLoading(_ condition: Bool) -> some View {
        self.shimmer(
            when: Binding(
                get: { condition },
                set: { _ in }
            )
        )
    }
}
