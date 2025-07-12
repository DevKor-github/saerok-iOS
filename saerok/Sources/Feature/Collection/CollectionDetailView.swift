//
//  CollectionDetailView.swift
//  saerok
//
//  Created by HanSeung on 4/12/25.
//

import SwiftUI

struct CollectionDetailView: View {
    enum Route {
        case edit
    }
    
    let collectionID: Int
    let isFromMapView: Bool
    
    @State private var collectionBird: Local.CollectionDetail = .mockData[0]
    @State private var isLoading: Bool = true
    @State private var showPopup: Bool = false
    @State private var error: Error? = nil
    
    @State private var showShareSheet: Bool = false
    @State private var downloadedImage: UIImage?
    
    // MARK: - Environment
    
    @Environment(\.injected) private var injected: DIContainer
    
    // MARK: Navigation

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
            
            shareButton
        }
        .regainSwipeBack()
        .onAppear {
            fetchCollectionDetail()
        }
        .navigationDestination(for: CollectionDetailView.Route.self, destination: { route in
            switch route {
            case .edit:
                if let path = path {
                    CollectionFormView(mode: .edit(collectionBird), path: path)
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
                }
                navigationBar
            }
            .shimmer(when: $isLoading)
        }
        .customPopup(isPresented: $showPopup) { alertView }
        .ignoresSafeArea(.all)
    }
    
    var imageSection: some View {
        ReactiveAsyncImage(
            url: collectionBird.imageURL,
            scale: .medium,
            quality: 1.0,
            downsampling: true
        )
        .aspectRatio(contentMode: .fill)
        .frame(maxWidth: .infinity)
    }
    
    var descriptionSection: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 27) {
                noteView
                infoView
                Spacer()
            }
            .padding(.top, 43)
            
            nameView
        }
    }
    
    var nameView: some View {
        Text(collectionBird.birdName ?? "이름 모를 새")
            .font(.SRFontSet.headline2_2)
            .fontWeight(.bold)
            .padding(.vertical, 18)
            .padding(.horizontal, 21)
            .background(Color.srWhite)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 0)
    }
    
    var noteView: some View {
        Text(collectionBird.note)
            .font(.SRFontSet.body3_2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 20)
            .padding(.top, 12)
            .padding(.horizontal, 17)
            .background(Color.whiteGray)
            .cornerRadius(8)
    }
    
    var infoView: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image.SRIconSet.pin
                    .frame(.defaultIconSizeLarge, tintColor: .pointtext)
                VStack(alignment: .leading) {
                    Text(collectionBird.locationAlias)
                        .font(.SRFontSet.body2)
                    Text(collectionBird.address)
                        .font(.SRFontSet.caption3)
                        .foregroundStyle(.secondary)
                }
            }
            
            HStack {
                Image.SRIconSet.clock
                    .frame(.defaultIconSizeLarge, tintColor: .pointtext)

                Text(collectionBird.discoveredDate.korString)
                    .font(.SRFontSet.body2)
            }
            
            HStack {
                Image.SRIconSet.myFilled
                    .frame(.defaultIconSizeLarge, tintColor: .pointtext)

                Text(collectionBird.userNickname)
                    .font(.SRFontSet.body2)
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
    
    @ViewBuilder
    var trailingButtons: some View {
        HStack(spacing: 7) {
            toDogamButton
            
            additionalButton
        }
    }
    
    var navigationBar: some View {
        NavigationBar(
            leading: {
                leadingButton
            },
            trailing: {
                trailingButtons
            },
            backgroundColor: .clear
        )
        .padding(.top, 54)
    }
    
    @ViewBuilder
    var toDogamButton: some View {
        if let birdID = collectionBird.birdID {
            if let bindingPath = path {
                NavigationLink {
                    BirdDetailView(birdID: birdID, path: bindingPath)
                } label: {
                    Image.SRIconSet.toDogam.frame(.defaultIconSizeVeryLarge)
                }
            } else {
                Button {
                    injected.appState[\.routing.contentView.tabSelection] = .fieldGuide
                    injected.appState[\.routing.fieldGuideView.birdName] = collectionBird.birdName
                } label: {
                    Image.SRIconSet.toDogam.frame(.defaultIconSizeVeryLarge)
                }
            }
        }
    }
    
    @ViewBuilder
    var additionalButton: some View {
        if !isFromMapView {
            Button {
                if let paths = path {
                    paths.wrappedValue.append(Route.edit)
                }
            } label: {
                Image.SRIconSet.edit.frame(.defaultIconSizeLarge)
            }
            .srStyled(.iconButton)
        } else {
            Menu {
                Button {
                    showPopup = true
                } label: {
                    Label("신고하기", systemImage: "light.beacon.max")
                }
            } label: {
                Image.SRIconSet.option.frame(.defaultIconSizeLarge)
            }
            .srStyled(.iconButton)
        }
    }
    
    @ViewBuilder
    var shareSheetSection: some View {
        if let image = downloadedImage, showShareSheet {
            CollectionShareView(collection: collectionBird, isPresented: $showShareSheet, image: image)
        }
    }
    
    @ViewBuilder
    var shareButton: some View {
        if !isFromMapView {
            Button {
                showShareSheet.toggle()
            } label: {
                Image.SRIconSet.airplane
                    .frame(.floatingButton)
                    .padding(.horizontal, SRDesignConstant.defaultPadding)
            }
        } else {
            EmptyView()
        }
    }
}

private extension CollectionDetailView {
    // MARK: - Networking & Helpers
    
    func fetchCollectionDetail() {
        Task {
            if let collectionBird = try? await injected.interactors.collection.fetchCollectionDetail(id: collectionID) {
                self.collectionBird = collectionBird
                downloadImage(from: collectionBird.imageURL)
                isLoading = false
            }
        }
    }
    
    func downloadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                downloadedImage = image
            }
        }.resume()
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var path: NavigationPath = .init()
    CollectionDetailView(collectionID: 1, path: $path)
}
