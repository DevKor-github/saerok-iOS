//
//  FieldGuideView.swift
//  saerok
//
//  Created by HanSeung on 4/8/25.
//


import Combine
import SwiftData
import SwiftUI

enum Route: Hashable {
    case search
    case birdDetail(Local.Bird)
}

struct FieldGuideView: Routable {
    
    // MARK:  Dependencies
    
    @Environment(\.injected) private var injected: DIContainer
    
    // MARK:  Routable
    
    @State var routingState: Routing = .init()
    
    // MARK: Navigation
    
    @State var navigationPath = NavigationPath()

    // MARK: View State
    
    @State private var fieldGuide: [Local.Bird]
    @State private var fieldGuideState: Loadable<Void>
    @State private var filterKey: BirdFilter = .init()
    @State private var showSeasonSheet = false
    @State private var showHabitatSheet = false
    @State private var showSizeSheet = false
    
    // MARK:  Init
    
    init(state: Loadable<Void> = .notRequested) {
        self.fieldGuide = []
        self._fieldGuideState = .init(initialValue: state)
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            content
                .query(key: filterKey, results: $fieldGuide) { filterKey in
                    Query(
                        filter: filterKey.build(),
                        sort: \Local.Bird.name
                    )
                }
        }
        .onReceive(routingUpdate) { self.routingState = $0 }
    }
    
    @ViewBuilder
    private var content: some View {
        switch fieldGuideState {
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

private extension FieldGuideView {
    @ViewBuilder
    func loadedView() -> some View {
        VStack(spacing: 0) {
            navigationBar
            filterButtonSection
            gridSection
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .search:
                        FieldGuideSearchView(path: $navigationPath)
                    case .birdDetail(let bird):
                        BirdDetailView(bird, path: $navigationPath)
                    }
                }
                .onChange(of: routingState.birdName, initial: true, { _, name in
                    guard let name,
                          let bird = fieldGuide.first(where: { $0.name == name })
                    else { return }
                    navigationPath.append(Route.birdDetail(bird))
                })
                .onChange(of: navigationPath, { _, path in
                    if !path.isEmpty {
                        routingBinding.wrappedValue.birdName = nil
                    }
                })
        }
    }
    
    var navigationBar: some View {
        NavigationBar(
            leading: {
                Text("도감")
                    .font(.SRFontSet.h1)
            },
            trailing: {
                HStack(spacing: 12) {
                    Button {
                        filterKey.isBookmarked.toggle()
                    } label: {
                        Image(filterKey.isBookmarked ? .bookmarkFill : .bookmark)
                            .foregroundStyle(filterKey.isBookmarked ? .main : .black)
                    }
                
                    Button {
                        navigationPath.append(Route.search)
                    } label: {
                        Image(.magnifyingglass)
                    }
                    .buttonStyle(.plain)
                }
                .font(.system(size: 24))
            }
        )
    }
    
    var filterButtonSection: some View {
        FilterBar(
            showSeasonSheet: $showSeasonSheet,
            showHabitatSheet: $showHabitatSheet,
            showSizeSheet: $showSizeSheet,
            filterKey: $filterKey
        )
    }
    
    var gridSection: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 15),
                    GridItem(.flexible(), spacing: 15)
                ],
                spacing: 15
            ) {
                ForEach(fieldGuide) { bird in
                    Button {
                        injected.appState[\.routing.fieldGuideView.birdName] = bird.name
                    } label: {
                        BirdCardView(bird)
                    }
                    .buttonStyle(.plain)
                }
                Group {
                    Rectangle()
                    Rectangle()
                }
                .foregroundStyle(.clear)
                .frame(height: 60)
            }
            .padding(SRDesignConstant.defaultPadding)
        }
        .background(Color.background)
    }
}

// MARK: - Loading Content

private extension FieldGuideView {
    func defaultView() -> some View {
        Text("")
            .onAppear {
                if !fieldGuide.isEmpty {
                    fieldGuideState = .loaded(())
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

private extension FieldGuideView {
    func loadFieldGuide() {
        $fieldGuideState.load {
            try await injected.interactors.fieldGuide.refreshFieldGuide()
        }
    }
}

// MARK: - Routable

extension FieldGuideView {
    struct Routing: Equatable {
        var birdName: String?
    }
    
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.fieldGuideView)
    }
    
    var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.fieldGuideView)
    }
}

#Preview {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    appDelegate.rootView
}
