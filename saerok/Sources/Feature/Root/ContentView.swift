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
    @State private var isCommunityMenuOpen: Bool = false
    
    // MARK: Dependencies
    @Environment(\.injected) private var injected
    @EnvironmentObject private var coordinator: AppCoordinator
        
    var body: some View {
        content
            .onReceive(injected.appStore.updates(for: \.routing.contentView.tabSelection)) {
                selectedTab = $0
            }
            .onAppear(perform: configureNavigationBar)
            .onAppear {
                let _ = coordinator.fieldGuideViewModel // lazy 강제초기화
            }
    }
    
    private var content: some View {
        AppNavigationHost(
            coordinator: coordinator,
            selectedTab: selectedTab,
            isCommunityMenuOpen: $isCommunityMenuOpen
        )
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

private struct AppNavigationHost: View {
    @Environment(\.injected) private var injected
    @ObservedObject private var navigation: AppNavigationState
    private let selectedTab: TabbedItems
    @Binding private var isCommunityMenuOpen: Bool

    init(
        coordinator: AppCoordinator,
        selectedTab: TabbedItems,
        isCommunityMenuOpen: Binding<Bool>
    ) {
        self.selectedTab = selectedTab
        self._isCommunityMenuOpen = isCommunityMenuOpen
        self._navigation = ObservedObject(wrappedValue: coordinator.navigation)
    }

    var body: some View {
        NavigationStack(path: $navigation.path) {
            ZStack {
                CachedTabContainer(selectedTab: selectedTab, isCommunityMenuOpen: $isCommunityMenuOpen)
                TabbarView(
                    selectedTab: selectedTab,
                    onTabSelected: { injected.appStore.send(.selectTab($0)) },
                    onScrollToTop: { tab in
                        switch tab {
                        case .fieldGuide: injected.appStore.send(.requestFieldGuideScrollToTop)
                        case .collection: injected.appStore.send(.requestCollectionScrollToTop)
                        default: break
                        }
                    },
                    isDimmed: isCommunityMenuOpen,
                    onDimTap: { isCommunityMenuOpen = false }
                )
            }
            .onboardingOverlay(type: selectedTab.onboardingType)
            .ignoresSafeArea(.all)
        }
        .srToast()
        .ignoresSafeArea(.all)
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
    @Binding var isCommunityMenuOpen: Bool

    init(selectedTab: TabbedItems, isCommunityMenuOpen: Binding<Bool>) {
        self.selectedTab = selectedTab
        self._isCommunityMenuOpen = isCommunityMenuOpen
    }

    var body: some View {
        TabContent(tab: selectedTab, isCommunityMenuOpen: $isCommunityMenuOpen)
    }
}

private struct TabContent: View {
    let tab: TabbedItems
    @Binding var isCommunityMenuOpen: Bool

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
            CommunityView(viewModel: coordinator.communityViewModel, showFloatingMenu: $isCommunityMenuOpen)
        case .profile:
            MyPageView(viewModel: coordinator.myPageViewModel)
        }
    }
}
