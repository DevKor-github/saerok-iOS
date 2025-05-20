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
    @State private var offsetY: CGFloat = 0
    
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
    
    // MARK: - Constants
    
    enum Constants {
        static let headerHeight: CGFloat = 100
        static let headerTopPadding: CGFloat = 20
        static let iconBackgroundSize: CGFloat = 40
        static let navBarSpacerHeight: CGFloat = 64
        static let scrollableID: String = "scrollable"
    }
    
    @ViewBuilder
    func loadedView() -> some View {
        ZStack(alignment: .topLeading) {
            headerBackgroundColor
            VStack(spacing: 0) {
                Color.clear.frame(height: Constants.navBarSpacerHeight)
                navigationBar
                scrollableSection
            }
        }
        .ignoresSafeArea(.all)
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
        .onPreferenceChange(ScrollPreferenceKey.self) { value in
            self.offsetY = value
        }
    }
    
    @ViewBuilder
    var headerBackgroundColor: some View {
        Color.srWhite
        Image(.blurTemplate)
            .opacity(opacityForScroll(offset: offsetY))
        Rectangle()
            .fill(.thinMaterial)
            .ignoresSafeArea()
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
                    .buttonStyle(.icon)
                }
            },
            backgroundColor: .clear
        )
    }
    
    var headerSection: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                Text("504")
                    .font(.SRFontSet.heavy)
                    .fontWeight(.semibold)
                    .foregroundStyle(.splash)
                Text("종의 새가 도감에 준비되어있어요.")
                    .font(.SRFontSet.caption1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            addButton
        }
        .frame(height: Constants.headerHeight)
        .padding(SRDesignConstant.defaultPadding)
    }
    
    var scrollableSection: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                OffsetReaderView()
                    .id(Constants.scrollableID)
                
                VStack(spacing: 0) {
                    headerSection
                    
                    StaggeredGrid(items: collections, columns: 2) { bird in
                        Button {
                            injected.appState[\.routing.collectionView.collection] = bird
                        } label: {
                            if let url = bird.imageURL.first {
                                VStack(alignment: .leading) {
                                    ReactiveAsyncImage(
                                        url: url,
                                        scale: .medium,
                                        quality: 0.8,
                                        downsampling: true
                                    )
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    
                                    Text(bird.bird?.name ?? "")
                                        .font(.SRFontSet.caption2)
                                        .padding(.leading, 8)
                                }
                                
                            } else if let imageData = bird.imageData.first {
                                VStack(alignment: .leading) {
                                    Image(uiImage: UIImage(data: imageData) ?? .birdPreview)
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    
                                    Text(bird.bird?.name ?? "")
                                        .font(.SRFontSet.caption2)
                                        .padding(.leading, 8)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal)
                    .background(Color.whiteGray)
                }
            }
            .onChange(of: offsetY) { _, newValue in
                if newValue == 0 {
                    withAnimation {
                        proxy.scrollTo(Constants.scrollableID, anchor: .top)
                    }
                }
            }
        }
    }
    
    var addButton: some View {
        Button {
            routingState.addCollection = true
            injected.appState[\.routing.addCollectionItemView.selectedBird] = nil
        } label: {
            Image.SRIconSet.penFill
                .frame(.defaultIconSizeVeryLarge)
                .foregroundStyle(.black)
                .background(
                    Circle().fill(.glassWhite)
                        .frame(width: 61, height: 61)
                )
                .frame(width: 61, height: 61)
        }
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

struct StaggeredGrid<Content: View, T: Hashable>: View {
    var items: [T]
    var columns: Int
    var spacing: CGFloat
    var content: (T) -> Content
    
    init(items: [T], columns: Int, spacing: CGFloat = 8, @ViewBuilder content: @escaping (T) -> Content) {
        self.items = items
        self.columns = columns
        self.spacing = spacing
        self.content = content
    }
    
    private func generateColumns() -> [[T]] {
        var grid: [[T]] = Array(repeating: [], count: columns)
        var heights: [CGFloat] = Array(repeating: 0, count: columns)
        
        for item in items {
            if let minIndex = heights.enumerated().min(by: { $0.element < $1.element })?.offset {
                grid[minIndex].append(item)
                heights[minIndex] += 1
            }
        }
        return grid
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: spacing) {
            ForEach(generateColumns(), id: \.self) { columnItems in
                VStack(spacing: spacing) {
                    ForEach(columnItems, id: \.hashValue) { item in
                        content(item)
                    }
                    
                    Group {
                        Rectangle()
                        Rectangle()
                    }
                    .foregroundStyle(.clear)
                    .frame(height: 200)
                }
            }
        }
        .padding(.vertical)
    }
}

#Preview {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    appDelegate.rootView
}
