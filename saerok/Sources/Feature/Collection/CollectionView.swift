//
//  CollectionView.swift
//  saerok
//
//  Created by HanSeung on 4/17/25.
//


import Combine
import SwiftData
import SwiftUI

struct CollectionView: Routable {
    enum Route: Hashable {
        case collectionDetail(_ collection: Local.CollectionBird)
        case addCollection
    }
    
    // MARK:  Dependencies
    
    @Environment(\.injected) private var injected: DIContainer
    @Environment(\.scenePhase) private var scenePhase

    // MARK:  Routable
    
    @State var routingState: Routing = .init()
    
    // MARK: Navigation
    
    @State internal var navigationPath = NavigationPath()
    
    // MARK: View State
    
    @State private var collections: [Local.CollectionBird]
    @State private var collectionState: Loadable<Void>
    @State private var filterKey: BirdFilter = .init()

    // MARK:  Init
    
    init(state: Loadable<Void> = .notRequested) {
        self.collections = []
        self._collectionState = .init(initialValue: state)
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            content
                .query(key: filterKey, results: $collections) { filterKey in
                    Query(
                        filter: filterKey.buildForCollection(),
                        sort: \Local.CollectionBird.latitude
                    )
                }
        }
        .onReceive(routingUpdate) { self.routingState = $0 }
    }
    
    @ViewBuilder
    private var content: some View {
        switch collectionState {
        case .notRequested:
            defaultView()
        case .isLoading:
            loadingView()
        case .loaded:
            loadedView()
        case let .failed(error):
            failedView(error)
        }
    }
}

// MARK: - Loaded Content

private extension CollectionView {
    @ViewBuilder
    func loadedView() -> some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                navigationBar
                listSection
                    .navigationDestination(for: CollectionView.Route.self, destination: { route in
                        switch route {
                        case .collectionDetail(let collection):
                            CollectionDetailView(collection, path: $navigationPath)
                        case .addCollection:
                            AddCollectionItemView(path: $navigationPath)
                        }
                    })
                    .onChange(of: routingState.collection, initial: true, { _, collection in
                        guard let collection else { return }
                        
                        navigationPath.append(Route.collectionDetail(collection))
                    })
                    .onChange(of: routingState.addCollection, initial: true, { _, isTrue in
                        if isTrue {
                            navigationPath.append(Route.addCollection)
                        }
                    })
                    .onChange(of: navigationPath, { _, path in
                        if !path.isEmpty {
                            routingBinding.wrappedValue.collection = nil
                        }
                    })
            }
            
            Button {
                routingState.addCollection = true
                injected.appState[\.routing.addCollectionItemView.selectedBird] = nil
            } label: {
                Image.SRIconSet.floatingButton
                    .frame(.floatingButton)
                    .shadow(color: .black.opacity(0.15), radius: 4)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 114)
            .padding(.trailing, SRDesignConstant.defaultPadding)

            
        }
    }
    
    var navigationBar: some View {
        NavigationBar(
            leading: {
                Text("나의 새록")
                    .font(.SRFontSet.headline1)
            },
            trailing: {
                HStack(spacing: 12) {                    
                    Button {
                        // TODO: 검색기능
                    } label: {
                        Image.SRIconSet.search
                            .frame(.defaultIconSizeLarge)
                    }
                }
                .font(.system(size: 24))
            }
        )
    }
    
    var listSection: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ForEach(collections) { bird in
                Button {
                    injected.appState[\.routing.collectionView.collection] = bird
                } label: {
                    BirdCollectionCardView(bird)
                }
                .buttonStyle(.plain)
            }
            .padding(SRDesignConstant.defaultPadding)
        }
        .background(Color.whiteGray)
    }
}

// MARK: - Loading Content

private extension CollectionView {
    func defaultView() -> some View {
        Text("")
            .onAppear {
                if !collections.isEmpty {
                    collectionState = .loaded(())
                }
                loadFieldGuide()
            }
    }
    
    func loadingView() -> some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
    }
    
    func failedView(_ error: Error) -> some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
    }
}

// MARK: - Side Effects

private extension CollectionView {
    func loadFieldGuide() {
        $collectionState.load {
            try await injected.interactors.collection.refreshCollection()
        }
    }
}

// MARK: - Routable

extension CollectionView {
    struct Routing: Equatable {
        var collection: Local.CollectionBird?
        var addCollection: Bool = false
    }
    
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.collectionView)
    }
    
    var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.collectionView)
    }
}

#Preview {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    appDelegate.rootView
}
