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
    }
    
    // MARK: - Properties

    let collectionID: Int
    let isFromMapView: Bool
    
    @State private var collection: Local.CollectionDetail = .mockData[0]
    @State private var collectionImage: UIImage?
    @State private var comments: [Local.CollectionComment] = []

    // MARK:  View State

    @State private var isLoading: Bool = true
    @State private var showPopup: Bool = false
    @State private var showCommentSheet: Bool = false
    @State private var showShareSheet: Bool = false
    
    @State private var error: Error? = nil
    @State private var text: String = ""
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

            shareSheetSection

            if !showCommentSheet {
                shareButton
            }
        }
        .regainSwipeBack()
        .onAppear {
            fetchCollectionDetail()
            fetchCollectionComments()
        }
        .navigationDestination(for: CollectionDetailView.Route.self, destination: { route in
            switch route {
            case .edit:
                if let path = path {
                    CollectionFormView(mode: .edit(collection), path: path)
                }
            }
        })
    }
}

// MARK: - Subviews

private extension CollectionDetailView {
    var content: some View {
        ScrollView {
            ZStack(alignment: .top) {
                VStack(alignment: .center, spacing: 0) {
                    imageSection
                    descriptionSection
                        .padding(.horizontal, SRDesignConstant.defaultPadding)
                        .offset(y: -30)
                    Color.clear
                        .frame(height: 40)
                }
                navigationBar
            }
            .shimmer(when: $isLoading)
            Spacer()
        }
        .background(Color.lightGray)
        .bottomSheet(isShowing: $showCommentSheet, backgroundColor: .lightGray, keyboard: keyboard) {
            CollectionCommentSheet(
                nickname: collection.userNickname,
                comments: comments,
                onDelete: deleteComment,
                onReport: { showPopup = true },
                onDismiss: { showCommentSheet.toggle() }
            )
        }
        .onTapGesture {
            isFocused = false
        }
        .commentInputOverlay(isPresented: $showCommentSheet) {
            CollectionCommentInputBar(
                text: $text,
                isFocused: _isFocused,
                nickname: collection.userNickname,
                onSubmit: postComment,
                keyboard: keyboard
            )
        }
        .customPopup(isPresented: $showPopup) { alertView }
        .ignoresSafeArea(.all)
    }

    var navigationBar: some View {
        NavigationBar(
            leading: {
                leadingButton
            },
            backgroundColor: .clear
        )
        .padding(.top, 54)
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
    
    var imageSection: some View {
        ReactiveAsyncImage(
            url: collection.imageURL,
            scale: .medium,
            quality: 1.0,
            downsampling: true
        )
        .scaledToFill()
        .frame(width: UIScreen.main.bounds.width)
        .clipped()
        .cornerRadius(20)
    }
    
    var descriptionSection: some View {
        CollectionDescriptionSection(
            collection: collection,
            isFromMapView: isFromMapView,
            path: path,
            onLikeToggle: { toggleLike() },
            onCommentTap: { showCommentSheet.toggle() },
            onReportTap: { showPopup.toggle() }
        )
    }

    @ViewBuilder
    var shareSheetSection: some View {
        if let image = collectionImage, showShareSheet {
            CollectionShareView(collection: collection, isPresented: $showShareSheet, image: image)
        }
    }
    
    @ViewBuilder
    var shareButton: some View {
        if !isFromMapView {
            Button(action: { showShareSheet.toggle() }) {
                Image.SRIconSet.airplane
                    .frame(.floatingButton)
                    .padding(.horizontal, SRDesignConstant.defaultPadding)
            }
        } else {
            EmptyView()
        }
    }
    
    var alertView: CustomPopup<DeleteButtonStyle, ConfirmButtonStyle, PrimaryButtonStyle> {
        CustomPopup(
            title: "게시물을 신고하시겠어요?",
            message: "커뮤니티 가이드에 따라\n신고 사유에 해당하는지 검토 후 처리돼요.",
            leading: .init(
                title: "신고하기",
                action: {
                    showPopup = false
                },
                style: .delete
            ),
            trailing: .init(
                title: "돌아가기",
                action: { showPopup = false },
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
            if let collectionBird = try? await injected.interactors.collection.fetchCollectionDetail(id: collectionID) {
                self.collection = collectionBird
                downloadImage(from: collectionBird.imageURL)
                isLoading = false
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
    
    func postComment() {
        Task {
            do {
                try await injected.interactors.collection.createComments(id: collectionID, text)
                comments = try await injected.interactors.collection.fetchComments(collectionID)
            } catch {
                
            }
            text = ""
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

