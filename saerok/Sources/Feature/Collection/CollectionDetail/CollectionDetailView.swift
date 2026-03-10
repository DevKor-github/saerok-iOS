//
//  CollectionDetailView.swift
//  saerok
//
//  Created by HanSeung on 4/12/25.
//

import SwiftUI

enum CollectionDetailRoute: AppRoute {
    case edit
    case findBird
    case preview
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
        var showCommentSheet: Bool = false
        var showSuggestionSheet: Bool = false
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
                alertView: postReportAlertView,
                adoptView: adoptAlertView,
                suggestAlertView: suggestAlertView
            )
            
            if !(uiState.showCommentSheet || uiState.showSuggestionSheet) {
                interactionZone
            }
            
            shareSheetSection
            
            if !(uiState.showCommentSheet || uiState.showSuggestionSheet) {
                shareButton
            }
            
            if viewModel.loadState == .invalid {
                InvalidAlertView(action: { coordinator.pop() })
                    .ignoresSafeArea(.all)
            }
        }
        .regainSwipeBack()
        .task {
            await viewModel.loadInitial()
            downloadImage(from: viewModel.collection.imageURL)
        }
        .navigationDestination(for: Route.self) { route in
            routeView(for: route)
        }
    }
}

// MARK: - Navigation
private extension CollectionDetailView {
    @ViewBuilder
    func routeView(for route: Route) -> some View {
        switch route {
        case .edit:
            CollectionFormView(viewModel: coordinator.makeCollectionFormViewModel(mode: .edit(viewModel.collection)))
        case .bird(let id):
            BirdDetailView(viewModel: coordinator.makeBirdDetailViewModel(birdID: id))
        case .findBird:
            CollectionSearchView(
                onSelect: { bird in
                    viewModel.selectSuggestingBird(bird)
                    coordinator.pop()
                })
        case .preview:
            if let suggestion = viewModel.selectedPreview {
                BirdDetailView(viewModel: coordinator.makeBirdDetailViewModel(birdID: suggestion.bird.id))
            }
        case .other(let id):
            UserSummaryView(viewModel: coordinator.makeUserSummaryViewModel(id))
        }
    }
}

private extension CollectionDetailView {
    var content: some View {
        ZStack(alignment: .top) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .center, spacing: 0) {
                    Color.clear
                        .frame(height: 57)
                    
                    imageSection
                        .shimmerIfLoading(viewModel.loadState != .loaded)
                    
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
                collectionUserId: viewModel.collection.user.id,
                isMyCollection: viewModel.collection.isMine,
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
                nickname: viewModel.collection.user.nickname,
                onSubmit: {
                    await viewModel.postComment(
                        text: uiState.text,
                        parentId: uiState.selectedComment?.id
                    )
                    uiState.selectedComment = nil
                },
                isFocused: _isFocused,
                keyboard: keyboard,
                isGuest: viewModel.isGuest
            )
        }
        .bottomSheet(isShowing: $uiState.showSuggestionSheet, keyboard: keyboard, isExtendable: false) {
            SuggestionSheet(
                isMine: viewModel.collection.isMine,
                collectionID: viewModel.collection.id,
                nickname: viewModel.collection.user.nickname,
                suggestions: $viewModel.suggestions,
                selectedBird: $viewModel.newSuggesting,
                selectedPreview: $viewModel.selectedPreview,
                selectedAdopting: $viewModel.selectedAdopting,
                opinionFlow: $viewModel.opinionFlow,
                showSuggestPopup: $uiState.showSuggestPopup,
                showAdoptPopup: $uiState.showAdoptPopup,
                onDismiss: { uiState.showSuggestionSheet.toggle() },
                onFindBird: {
                    coordinator.push(Route.findBird)
                    viewModel.sendFindBirdLog()
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
                    .frame(.defaultIconSize)
            }
            .srStyled(.iconButton)
        }
    }
    
    @ViewBuilder
    var imageSection: some View {
        let image = ReactiveAsyncImageWithMetadata(
            url: viewModel.collection.imageURL,
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
    
    var descriptionSection: some View {
        CollectionDescriptionSection(
            collection: viewModel.collection,
        ) { action in
            switch action {
            case .reportTap:
                uiState.showPopup.toggle()
                
            case .suggestTap:
                uiState.showSuggestionSheet.toggle()
                viewModel.startOpinionFlow()
                
            case .navigateToFieldGuide:
                viewModel.navigateToFieldGuide()
                
            case .navigateToMap:
                viewModel.navigateToMap()
                
            case .navigateToOther(let userId):
                coordinator.push(Route.other(userId))
            }
        }
    }
    
    private var interactionZone: some View {
        InteractionZone(
            variant: variant,
            collection: viewModel.collection,
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
    
    @ViewBuilder
    var shareSheetSection: some View {
        if let image = uiState.collectionImage,
           uiState.showShareSheet
        {
            CollectionShareView(
                collection: viewModel.collection,
                isPresented: $uiState.showShareSheet,
                image: image
            )
        }
    }
    
    @ViewBuilder
    var shareButton: some View {
        if viewModel.collection.isMine {
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
                        coordinator.push(Route.preview)
                    } label: {
                        Image.SRIconSet.chevronRight
                            .frame(.defaultIconSize)
                    }
                    .buttonStyle(.icon)
                    .padding(4)
                }
            }
        }
    }
    
    var postReportAlertView: CustomPopup<DeleteButtonStyle, ConfirmButtonStyle, PrimaryButtonStyle> {
        CustomPopup(
            title: "게시물을 신고하시겠어요?",
            message: "커뮤니티 가이드에 따라\n신고 사유에 해당하는지 검토 후 처리돼요.",
            leading: .init(
                title: "신고하기",
                action: {
                    Task {
                        await viewModel.reportCollection()
                        uiState.showPopup = false
                    }
                },
                style: .delete
            ),
            trailing: .init(
                title: "돌아가기",
                action: { uiState.showPopup = false },
                style: .confirm
            ),
            center: nil
        )
    }
    
    var suggestAlertView: CustomPopup<BorderedButtonStyle, ConfirmButtonStyle, PrimaryButtonStyle> {
        CustomPopup(
            title: "'\(viewModel.newSuggesting?.name ?? "딱새")'가 맞나요?",
            message: "정확하지 않은 이름의 제안은 사용자들에게\n혼란을 일으킬 수 있어요.",
            leading: .init(
                title: "취소",
                action: {
                    uiState.showSuggestPopup = false
                    viewModel.suggestingCancel()
                },
                style: .bordered
            ),
            trailing: .init(
                title: "동정돕기",
                action: {
                    Task {
                        await viewModel.suggestingComplete()
                        uiState.showSuggestPopup = false
                    }
                },
                style: .confirm
            ),
            center: nil
        )
    }
    
    var adoptAlertView: CustomPopup<BorderedButtonStyle, ConfirmButtonStyle, PrimaryButtonStyle> {
        CustomPopup(
            title: "'\(viewModel.selectedAdopting?.bird.name ?? "딱새")'로 채택하시겠어요?",
            message: "채택된 이후 동정 돕기 창은 사라지며,\n다시 이름 모를 새로 전환하면\n보이게 할 수 있어요.",
            leading: .init(
                title: "취소",
                action: {
                    uiState.showAdoptPopup = false
                },
                style: .bordered
            ),
            trailing: .init(
                title: "채택하기",
                action: {
                    Task {
                        await viewModel.adoptBird()
                        uiState.showAdoptPopup = false
                    }
                },
                style: .confirm
            ),
            center: nil
        )
    }
    
    func downloadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data, let image = UIImage(data: data) else { return }
            Task { @MainActor in
                uiState.collectionImage = image
            }
        }.resume()
    }
}

extension View {
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

struct CollectionPopupLayer: View {
    @Binding var showPopup: Bool
    @Binding var showSuggestPopup: Bool
    @Binding var showAdoptPopup: Bool
    let alertView: CustomPopup<DeleteButtonStyle, ConfirmButtonStyle, PrimaryButtonStyle>
    let adoptView: CustomPopup<BorderedButtonStyle, ConfirmButtonStyle, PrimaryButtonStyle>
    let suggestAlertView: CustomPopup<BorderedButtonStyle, ConfirmButtonStyle, PrimaryButtonStyle>
    
    var body: some View {
        EmptyView()
            .customPopup(isPresented: $showPopup) { alertView }
            .customPopup(isPresented: $showSuggestPopup) { suggestAlertView }
            .customPopup(isPresented: $showAdoptPopup) { adoptView }
    }
}

private struct InvalidAlertView: View {
    let action: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .transition(.opacity)
                .zIndex(1)
            CustomPopup<BorderedButtonStyle, PrimaryButtonStyle, ConfirmButtonStyle>(
                title: "존재하지 않는 새록이에요",
                message: "새록이 삭제되었거나\n데이터를 불러올 수 없어요.",
                leading: nil,
                trailing: nil,
                center: .init(
                    title: "확인",
                    action: action,
                    style: .confirm
                )
            )
            .zIndex(10)
            .transition(.scale)
        }
    }
}
