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
    
    // MARK:  Dependencies
    
    @Environment(\.injected) private var injected: DIContainer
    
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
        VStack(spacing: 0) {
            navigationBar
            listSection
                .navigationDestination(for: Local.Bird.self, destination: { bird in
                    BirdDetailView(bird, path: $navigationPath)
                })
                .onAppear {
                    injected.appState[\.routing.contentView.isTabbarHidden] = false
                }
                .onChange(of: routingState.birdID, initial: true, { _, id in
                    guard let id,
                          let bird = collections.first(where: { $0.persistentModelID == id })
                    else { return }
                    navigationPath.append(bird)
                })
                .onChange(of: navigationPath, { _, path in
                    if !path.isEmpty {
                        routingBinding.wrappedValue.birdID = nil
                    }
                })
        }
    }
    
    var navigationBar: some View {
        NavigationBar(
            leading: {
                Text("컬렉션")
                    .font(.SRFontSet.h1)
            },
            trailing: {
                HStack(spacing: 12) {                    
                    Button {
                        // TODO: 검색기능
                    } label: {
                        Image(.magnifyingglass)
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
                    //
                } label: {
                    BirdCollectionCardView(bird)
                }
                .buttonStyle(.plain)
            }
            .padding(SRDesignConstant.defaultPadding)
        }
        .background(Color.background)
    }
    
//    var seasonFilterButton: some View {
//        let isActive = !filterKey.selectedSeasons.isEmpty
//        
//        return Button {
//            showSeasonSheet.toggle()
//        } label: {
//            HStack(spacing: 4) {
//                Image(.calendar)
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 16)
//                Text(!isActive ? "계절" : filterKey.selectedSeasons.map { $0.rawValue }.joined(separator: " • "))
//                    .font(.SRFontSet.h3)
//            }
//        }
//        .srStyled(.filterButton(isActive: isActive))
//        .sheetEnumPicker(
//            isPresented: $showSeasonSheet,
//            title: "계절 선택",
//            selection: $filterKey.selectedSeasons,
//            presentationDetents: [.fraction(0.3)]
//        )
//    }
//    
//    var habitatFilterButton: some View {
//        let isActive = !filterKey.selectedHabitats.isEmpty
//        
//        return Button {
//            showHabitatSheet.toggle()
//        } label: {
//            HStack(spacing: 4) {
//                Image(.tree)
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 16)
//                Text(!isActive ? "서식지" : filterKey.selectedHabitats.map { $0.rawValue }.joined(separator: " • "))
//                    .font(.SRFontSet.h3)
//            }
//        }
//        .srStyled(.filterButton(isActive: isActive))
//        .sheetEnumPicker(
//            isPresented: $showHabitatSheet,
//            title: "계절 선택",
//            selection: $filterKey.selectedHabitats,
//            presentationDetents: [.fraction(0.4)]
//        )
//    }
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
        var birdID: PersistentIdentifier?
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
