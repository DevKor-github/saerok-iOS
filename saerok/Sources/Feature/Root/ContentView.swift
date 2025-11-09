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
        content
            .onReceive(routingUpdate) { routingState = $0 }
            .onChange(of: routingState.tabSelection, initial: true) { _, tab in
                selectedTab = tab
            }
            .onChange(of: routingState.isTabbarHidden, initial: true) { _, hidden in
                isTabbarHidden = hidden
            }
            .onAppear(perform: configureNavigationBar)
    }
    
    private var content: some View {
        NavigationStack(path: $path) {
            ZStack {
                CachedTabContainer(selectedTab: selectedTab, path: $path)
                
                TabbarView(selectedTab: selectedTab)
                    .opacity(routingState.isTabbarHidden ? 0 : 1)
                    .allowsHitTesting(!routingState.isTabbarHidden)
            }
            .onboardingOverlay(type: selectedTab.onboardingType)
            .ignoresSafeArea(.all)
        }
        .ignoresSafeArea(.all)
    }
    
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .srWhite
        appearance.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - Routable

extension ContentView {
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
    @Binding var path: NavigationPath
    @State private var cache: [TabbedItems: AnyView] = [:]

    var body: some View {
        ZStack {
            ForEach(TabbedItems.allCases, id: \.self) { tab in
                let isSelected = (selectedTab == tab)
                Group {
                    if tab == .map {
                        if isSelected {
                            MapView(path: $path)
                        } else {
                            EmptyView()
                        }
                    } else {
                        if let cached = cache[tab] {
                            cached
                        } else if isSelected {
                            let built = AnyView(TabContent(tab: tab, path: $path))
                            built
                                .onAppear {
                                    cache[tab] = built
                                }
                        } else {
                            EmptyView()
                        }
                    }
                }
                .opacity(isSelected ? 1 : 0)
                .scaleEffect(isSelected ? 1 : 0.98)
                .offset(y: isSelected ? 0 : 5)
                .animation(.spring(response: 0.15, dampingFraction: 0.9), value: selectedTab)
            }
        }
    }
}

private struct TabContent: View {
    let tab: TabbedItems
    @Binding var path: NavigationPath

    var body: some View {
        content
    }

    @ViewBuilder
    private var content: some View {
        switch tab {
        case .map:
            EmptyView()
        case .fieldGuide:
            FieldGuideView(path: $path)
        case .collection:
            CollectionView(path: $path)
        case .community:
            CommunityView(path: $path)
        case .profile:
            MyPageView(path: $path)
        }
    }
}
