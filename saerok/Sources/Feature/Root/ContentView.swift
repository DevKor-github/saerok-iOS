//
//  ContentView.swift
//  saerok
//
//  Created by HanSeung on 3/18/25.
//

import Combine
import SwiftUI

struct ContentView: Routable {

    // MARK: Dependencies

    @Environment(\.injected) var injected

    // MARK: Routing

    @State var routingState = Routing()

    // MARK: View State
    
    @State private var selectedTab: TabbedItems = SRConstant.mainTab
    @State private var isTabbarHidden: Bool = false
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                CachedTabContainer(selectedTab: selectedTab, path: $path)
                
                TabbarView(selectedTab: selectedTab)
                    .opacity(routingState.isTabbarHidden ? 0 : 1)
                    .allowsHitTesting(!routingState.isTabbarHidden)
            }
            .ignoresSafeArea(.all)
        }
        .ignoresSafeArea(.all)
        .onReceive(routingUpdate) { routingState = $0 }
        .onChange(of: routingState.tabSelection, initial: true) { _, tab in
            selectedTab = tab
        }
        .onChange(of: routingState.isTabbarHidden, initial: true) { _, hidden in
            isTabbarHidden = hidden
        }
        .onAppear(perform: configureNavigationBar)
    }

    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .srWhite
        appearance.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    struct Routing: Equatable {
        var tabSelection: TabbedItems = SRConstant.mainTab
        var isTabbarHidden: Bool = false
    }

    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.contentView)
    }

    var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.contentView)
    }
}

struct CachedTabContainer: View {
    let selectedTab: TabbedItems
    @State private var cache: [TabbedItems: AnyView] = [:]
    @Binding var path: NavigationPath

    var body: some View {
        ZStack {
            ForEach(TabbedItems.allCases, id: \.self) { tab in
                Group {
                    if tab == .home {
                        if selectedTab == .home {
                            MapView(path: $path)
                        } else {
                            EmptyView()
                        }
                    } else if let cached = cache[tab] {
                        cached
                    } else if selectedTab == tab {
                        LazyView(viewFor(tab, path: path))
                            .onAppear {
                                cache[tab] = AnyView(viewFor(tab, path: path))
                            }
                    } else {
                        EmptyView()
                    }
                }
                .opacity(selectedTab == tab ? 1 : 0)
                .scaleEffect(selectedTab == tab ? 1 : 0.98)
                .offset(y: selectedTab == tab ? 0 : 5)
                .animation(.spring(response: 0.15, dampingFraction: 0.9), value: selectedTab)
            }
        }
    }

    @ViewBuilder
    private func viewFor(_ tab: TabbedItems, path: NavigationPath) -> some View {
        switch tab {
        case .home:
            EmptyView()
        case .fieldGuide:
            FieldGuideView(path: $path)
        case .collection:
            CollectionView(path: $path)
        case .profile:
            MyPageView(path: $path)
        }
    }
}
