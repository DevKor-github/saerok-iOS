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
    @State private var isLoading = true
    @State private var error: Error? = nil

    // MARK:  Dependencies
    
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
    
    var body: some View {
        ScrollView {
            ZStack(alignment: .top) {
                VStack(alignment: .center, spacing: 0) {
                    imageSection
                    contentSection
                        .padding(SRDesignConstant.defaultPadding)
                }
                navigationBar
            }
            .shimmer(when: $isLoading)
        }
        .ignoresSafeArea(.all)
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

private extension CollectionDetailView {
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
    
    var contentSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading) {
                    Text(collectionBird.birdName ?? "어디선가 본 새")
                        .font(.SRFontSet.headline2)
                        .fontWeight(.bold)
                    Text(collectionBird.scientificName ?? "")
                        .font(.SRFontSet.body2)
                        .foregroundStyle(.srGray)
                }
                
                Spacer()
                
                if let birdID = collectionBird.birdID {
                    if let bindingPath = path {
                        NavigationLink {
                            BirdDetailView(birdID: birdID, path: bindingPath)
                        } label: {
                            HStack {
                                Text("도감 보기")
                                    .font(.SRFontSet.body1)
                                Image.SRIconSet.chevronRight
                                    .frame(.custom(width: 17, height: 17))
                            }
                            .foregroundStyle(Color.main)
                        }
                    } else {
                        Button {
                            injected.appState[\.routing.contentView.tabSelection] = .fieldGuide
                            injected.appState[\.routing.fieldGuideView.birdName] = collectionBird.birdName
                        } label: {
                            HStack {
                                Text("도감 보기")
                                    .font(.SRFontSet.body1)
                                Image.SRIconSet.chevronRight
                                    .frame(.custom(width: 17, height: 17))
                            }
                            .foregroundStyle(Color.main)
                        }
                    }
                }
   
            }
            
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Image.SRIconSet.pin.frame(.defaultIconSizeLarge)
                    VStack(alignment: .leading) {
                        Text(collectionBird.locationAlias)
                            .font(.SRFontSet.body2)
                        Text(collectionBird.address)
                            .font(.SRFontSet.caption3)
                            .foregroundStyle(.secondary)
                    }
                }
                
                HStack {
                    Image.SRIconSet.clock.frame(.defaultIconSizeLarge)
                    
                    Text(collectionBird.discoveredDate.toFullString)
                        .font(.SRFontSet.body2)
                }
            }
            
            Text(collectionBird.note)
                .font(.SRFontSet.caption1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 13)
                .padding(.horizontal, 17)
                .background(Color.whiteGray)
                .cornerRadius(8)
            Spacer()
        }
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
        if !isFromMapView {
            HStack(spacing: 7) {
                Button(action: {
                    
                }) {
                    Image.SRIconSet.insta.frame(.defaultIconSizeLarge)
                }
                
                Button(action: {
                    if let paths = path {
                        paths.wrappedValue.append(Route.edit)
                    }
                }) {
                    Image.SRIconSet.edit.frame(.defaultIconSizeLarge)
                }
            }
            .srStyled(.iconButton)
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
}

private extension CollectionDetailView {
    func fetchCollectionDetail() {
        Task {
            if let collectionBird = try? await injected.interactors.collection.fetchCollectionDetail(id: collectionID) {
                self.collectionBird = collectionBird
            }
            isLoading = false
        }
    }
}

#Preview {
    @Previewable @State var path: NavigationPath = .init()
    CollectionDetailView(collectionID: 1, path: $path)
}
