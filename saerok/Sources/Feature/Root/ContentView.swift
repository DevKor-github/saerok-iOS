//
//  ContentView.swift
//  saerok
//
//  Created by HanSeung on 3/18/25.
//

import Combine
import SwiftUI

struct ContentView: View {
    @State private var selectedTab: TabbedItems = SRConstant.mainTab
    
    // MARK: Dependencies
    @Environment(\.injected) private var injected
    @EnvironmentObject private var coordinator: AppCoordinator
        
    var body: some View {
        content
            .onReceive(injected.appState.updates(for: \.routing.contentView.tabSelection)) {
                selectedTab = $0
            }
            .onAppear(perform: configureNavigationBar)
            .onAppear {
                let _ = coordinator.fieldGuideViewModel // lazy 강제초기화
            }
    }
    
    private var content: some View {
        NavigationStack(path: $coordinator.path) {
            ZStack {
                CachedTabContainer(selectedTab: selectedTab)
                TabbarView(selectedTab: selectedTab)
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
    }
}

struct CachedTabContainer: View {
    let selectedTab: TabbedItems
    @State private var initializedTabs: Set<TabbedItems> = []

    init(selectedTab: TabbedItems) {
        self.selectedTab = selectedTab
    }
    
    var body: some View {
        ZStack {
            ForEach(TabbedItems.allCases, id: \.self) { tab in
                let isSelected = selectedTab == tab

                Group {
                    if initializedTabs.contains(tab) {
                        TabContent(tab: tab)
                    } else if isSelected {
                        TabContent(tab: tab)
                            .onAppear {
                                initializedTabs.insert(tab)
                            }
                    }
                }
                .opacity(isSelected ? 1 : 0)
                .scaleEffect(isSelected ? 1 : 0.99)
                .offset(y: isSelected ? 0 : 5)
                .animation(.spring(response: 0.15, dampingFraction: 0.9), value: selectedTab)
            }
        }
    }
}

private struct TabContent: View {
    let tab: TabbedItems
    
    @EnvironmentObject private var coordinator: AppCoordinator
    
    var body: some View {
        content
    }

    @ViewBuilder
    private var content: some View {
        switch tab {
        case .map:
            MapView(viewModel: coordinator.mapViewModel)
        case .fieldGuide:
            FieldGuideView(viewModel: coordinator.fieldGuideViewModel)
        case .collection:
            CollectionView(viewModel: coordinator.collectionViewModel)
        case .community:
            CommunityView(viewModel: coordinator.communityViewModel)
        case .profile:
            MyPageView(viewModel: coordinator.myPageViewModel)
        }
    }
}
