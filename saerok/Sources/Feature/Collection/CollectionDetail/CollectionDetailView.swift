//
//  CollectionDetailView.swift
//  saerok
//
//  Created by HanSeung on 4/12/25.
//

import SwiftUI

struct CollectionDetailView: View {
    
    // MARK:  Route

    enum Route {
        case edit
        case findBird
        case preview
    }
    
    enum LoadState {
        case loading
        case loaded
        case invalid
    }
    
    struct CollectionUIState: Equatable {
        var isLoading: LoadState = .loading
        var showPopup: Bool = false
        var showSuggestPopup: Bool = false
        var showAdoptPopup: Bool = false
        var showCommentSheet: Bool = false
        var showSuggestionSheet: Bool = false
        var showShareSheet: Bool = false
        var text: String = ""
    }
    
    // MARK: - Properties

    let collectionID: Int
    let isFromMapView: Bool
    
    @State private var collection: Local.CollectionDetail = .mockData[0]
    @State private var collectionImage: UIImage?
    @State private var comments: [Local.CollectionComment] = []
    @State private var suggestions: [Local.BirdSuggestion] = Local.BirdSuggestion.mockData
    @State private var newSuggesting: Local.Bird? = nil
    @State private var selectedPreview: Local.BirdSuggestion? = nil
    @State private var selectedAdopting: Local.BirdSuggestion? = nil
    
    // MARK:  View State

    @State private var uiState = CollectionUIState()
    @State private var error: Error? = nil
    @FocusState private var isFocused
    @StateObject private var keyboard = KeyboardObserver()
    
    // MARK: - Environment
    
    @Environment(\.injected) private var injected: DIContainer
    
    // MARK: - Navigation
    
    var path: Binding<NavigationPath>?
    
    // MARK: - Init
    
    init(
        collectionID: Int,
        path: Binding<NavigationPath>? = nil,
        isFromMap: Bool = false
    ) {
        self.collectionID = collectionID
        self.path = path
        self.isFromMapView = isFromMap
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            content

            CollectionPopupLayer(
                showPopup: $uiState.showPopup,
                showSuggestPopup: $uiState.showSuggestPopup,
                showAdoptPopup: $uiState.showAdoptPopup,
                alertView: alertView,
                adoptView: adoptAlertView,
                suggestAlertView: suggestAlertView
            )
            
            shareSheetSection

            if !(uiState.showCommentSheet || uiState.showSuggestionSheet) {
                shareButton
            }
            
            if uiState.isLoading == .invalid {
                InvalidAlertView(action: { path?.wrappedValue.removeLast() })
                    .ignoresSafeArea(.all)
            }
        }
        .regainSwipeBack()
        .onAppear {
            fetchCollectionDetail()
            fetchCollectionComments()
            fetchSuggestion()
        }
        .navigationDestination(for: CollectionDetailView.Route.self, destination: { route in
            switch route {
            case .edit:
                if let path = path {
                    CollectionFormView(mode: .edit(collection), path: path)
                }
            case .findBird:
                if let path = path {
                    CollectionSearchView(
                        path: path,
                        onSelect: { bird in
                            newSuggesting = bird
                            path.wrappedValue.removeLast()
                        })
                }
            case .preview:
                if let bindingPath = path,
                   let suggestion = selectedPreview
                {
                    BirdDetailView(birdID: suggestion.bird.id, path: bindingPath)
                }
            }
        })
    }
}

// MARK: - Subviews

private extension CollectionDetailView {
    var content: some View {
        ZStack(alignment: .top) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .center, spacing: 0) {
                    Color.clear
                        .frame(height: 57)
                    imageSection
                    
                    descriptionSection
                        .padding(.horizontal, SRDesignConstant.defaultPadding)
                        .offset(y: -20)
                    
                    Color.clear
                        .frame(height: 40)
                }
                .shimmer(
                    when: Binding(
                        get: { uiState.isLoading != .loaded },
                        set: { _ in }
                    )
                )
                Spacer()
            }
            navigationBar
        }
        .background(Color.srLightGray)
        .bottomSheet(isShowing: $uiState.showCommentSheet, keyboard: keyboard) {
            CollectionCommentSheet(
                isMyCollection: !isFromMapView,
                nickname: collection.userNickname,
                comments: comments,
                onDelete: deleteComment,
                onReport: { uiState.showPopup = true },
                onDismiss: { uiState.showCommentSheet.toggle() },
            )
        }
        .onTapGesture {
            isFocused = false
        }
        .commentInputOverlay(isPresented: $uiState.showCommentSheet) {
            CollectionCommentInputBar(
                text: $uiState.text,
                isFocused: _isFocused,
                nickname: collection.userNickname,
                onSubmit: postComment,
                keyboard: keyboard
            )
        }
        .bottomSheet(isShowing: $uiState.showSuggestionSheet, keyboard: keyboard, isExtendable: false) {
            SuggestionSheet(
                isFromMap: isFromMapView,
                collectionID: collection.id,
                nickname: collection.userNickname,
                suggestions: $suggestions,
                selectedBird: $newSuggesting,
                selectedPreview: $selectedPreview,
                selectedAdopting: $selectedAdopting,
                showSuggestPopup: $uiState.showSuggestPopup,
                showAdoptPopup: $uiState.showAdoptPopup,
                onDismiss: { uiState.showSuggestionSheet.toggle() },
                onFindBird: findBird
            )
        }
        .topOverlay(observed: selectedPreview?.bird.id) { birdPreview }
        .ignoresSafeArea(.all)
    }

    var navigationBar: some View {
        NavigationBar(
            leading: {
                leadingButton
            },
            trailing: {
                trailingProfileImage
            },
            backgroundColor: .clear
        )
        .padding(.top, 60)
    }
    
    @ViewBuilder
    var leadingButton: some View {
        if path != nil {
            Button(action: {
                path?.wrappedValue.removeLast()
            }) {
                Image.SRIconSet.chevronLeft
                    .frame(.defaultIconSize)
            }
            .srStyled(.iconButton)
        }
    }
    
    var trailingProfileImage: some View {
        HStack {
            ReactiveAsyncImage(
                url: collection.profileImageUrl,
                scale: .small,
                quality: 0.5,
                downsampling: true
            )
            .frame(width: 25, height: 25)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .inset(by: 0.8)
                    .stroke(.srLightGray, lineWidth: 2)
            )
            .id(collection.id)
            
            Text(collection.userNickname)
                .font(.SRFontSet.body4)
        }
        .padding(.vertical, 7)
        .padding(.leading, 10)
        .padding(.trailing, 12)
        .background(Color.glassWhite)
        .clipShape(RoundedRectangle(cornerRadius: .infinity))
    }
    
    var imageSection: some View {
        ReactiveAsyncImage(
            url: collection.imageURL,
            scale: .medium,
            quality: 1.0,
            downsampling: true
        )
        .scaledToFill()
        .cornerRadius(35)
        .padding(.horizontal, 9)
        .frame(width: UIScreen.main.bounds.width)
        .clipped()
    }
    
    var descriptionSection: some View {
        CollectionDescriptionSection(
            collection: collection,
            isFromMapView: isFromMapView,
            path: path,
            onLikeToggle: { toggleLike() },
            onCommentTap: { uiState.showCommentSheet.toggle() },
            onReportTap: { uiState.showPopup.toggle() },
            onSuggestTap: { uiState.showSuggestionSheet.toggle() }
        )
    }

    @ViewBuilder
    var shareSheetSection: some View {
        if let image = collectionImage,
            uiState.showShareSheet
        {
            CollectionShareView(collection: collection, isPresented: $uiState.showShareSheet, image: image)
        }
    }
    
    @ViewBuilder
    var shareButton: some View {
        if !isFromMapView {
            Button(action: { uiState.showShareSheet.toggle() }) {
                Image.SRIconSet.airplane
                    .frame(.floatingButton)
                    .padding(.horizontal, SRDesignConstant.defaultPadding)
            }
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    var birdPreview: some View {
        if let suggestion = selectedPreview,
           uiState.showSuggestionSheet
        {
            ZStack(alignment: .bottomTrailing) {
                AsyncImage(
                    url: suggestion.bird.imageURL!,
                    size: CGSize(width: 220, height: 227),
                    scale: .medium,
                    quality: 0.8,
                    downsampling: true
                )
                .clipped()
                .frame(width: 220, height: 227)
                .cornerRadius(23)
                .padding(.top, 66)

                if let bindingPath = path {
                    Button {
                        bindingPath.wrappedValue.append(Route.preview)
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
    
    var alertView: CustomPopup<DeleteButtonStyle, ConfirmButtonStyle, PrimaryButtonStyle> {
        CustomPopup(
            title: "게시물을 신고하시겠어요?",
            message: "커뮤니티 가이드에 따라\n신고 사유에 해당하는지 검토 후 처리돼요.",
            leading: .init(
                title: "신고하기",
                action: {
                    Task {
                        try await injected.interactors.collection.reportCollection(collectionID)
                    }
                    uiState.showPopup = false
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
            title: "'\(newSuggesting?.name ?? "딱새")'가 맞나요?",
            message: "정확하지 않은 이름의 제안은 사용자들에게\n혼란을 일으킬 수 있어요.",
            leading: .init(
                title: "취소",
                action: {
                    uiState.showSuggestPopup = false
                    newSuggesting = nil
                },
                style: .bordered
            ),
            trailing: .init(
                title: "동정돕기",
                action: {
                    suggestBird(birdID: newSuggesting?.id ?? 0)
                    uiState.showSuggestPopup = false
                    newSuggesting = nil
                },
                style: .confirm
            ),
            center: nil
        )
    }
    
    var adoptAlertView: CustomPopup<BorderedButtonStyle, ConfirmButtonStyle, PrimaryButtonStyle> {
        CustomPopup(
            title: "'\(selectedAdopting?.bird.name ?? "딱새")'로 채택하시겠어요?",
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
                    adoptBird(birdId: selectedAdopting?.bird.id ?? 0)
                    uiState.showAdoptPopup = false
                },
                style: .confirm
            ),
            center: nil
        )
    }
}

// MARK: - Networking

private extension CollectionDetailView {
    func fetchCollectionDetail() {
        Task {
            do {
                let collectionBird = try await injected.interactors.collection.fetchCollectionDetail(id: collectionID)
                self.collection = collectionBird
                downloadImage(from: collectionBird.imageURL)
                uiState.isLoading = .loaded
            } catch {
                uiState.isLoading = .invalid
            }
        }
    }
    
    func fetchCollectionComments() {
        Task {
            do {
                comments = try await injected.interactors.collection.fetchComments(collectionID)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchSuggestion() {
        Task {
            let result = try await injected.interactors.collection.fetchBirdSuggestions(collectionID)
            suggestions = result
            if !result.isEmpty { selectedPreview = suggestions[0] }
        }
    }
    
    func postComment() {
        Task {
            do {
                try await injected.interactors.collection.createComments(id: collectionID, uiState.text)
                comments = try await injected.interactors.collection.fetchComments(collectionID)
            } catch {
                
            }
            uiState.text = ""
        }
    }
    
    func deleteComment(_ id: Int) {
        Task {
            do {
                try await injected.interactors.collection.deleteComment(collectionId: collectionID, commentId: id)
                collection.commentCount -= 1
                comments = try await injected.interactors.collection.fetchComments(collectionID)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func toggleLike() {
        Task {
            do {
                HapticManager.shared.trigger(.light)
                let isLiked = try await injected.interactors.collection.toggleLike(collectionID)
                collection.likeToggle(isLiked)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func findBird() {
        if let path = path {
            path.wrappedValue.append(CollectionDetailView.Route.findBird)
        }
    }
    
    func suggestBird(birdID: Int) {
        Task {
            do {
                var result = try await injected.interactors.collection.suggestBird(collectionID, birdId: birdID)
                let bird = try await injected.interactors.fieldGuide.loadBirdDetails(birdID: birdID)
                result.bird = bird
                
                suggestions.append(result)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func adoptBird(birdId: Int) {
        Task {
            try await injected.interactors.collection.adoptSuggestion(collectionID, birdId: birdId)
            uiState.showAdoptPopup = false
            uiState.showSuggestionSheet = false
            fetchCollectionDetail()
        }
    }
    
    func downloadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                collectionImage = image
            }
        }.resume()
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var path: NavigationPath = .init()
    CollectionDetailView(collectionID: 1, path: $path)
}


//#Preview {
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
//    
//    appDelegate.rootView
//}


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
