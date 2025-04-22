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
    
    // MARK: Routable
    
    @State var routingState: Routing = .init()
    
    // MARK: View State

    @State var selectedTab: Int = SRConstant.mainTab
    @State var isTabbarHidden: Bool = false
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .srWhite
        appearance.shadowColor = .clear 

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                switch selectedTab {
                case 1:
                    FieldGuideView()
                default:
                    Rectangle()
                        .foregroundStyle(.clear)
                }
                
                TabbarView(selectedTab: selectedTab)
                    .opacity(routingState.isTabbarHidden ? 0 : 1)
                    .allowsHitTesting(!routingState.isTabbarHidden)
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onReceive(routingUpdate) { self.routingState = $0 }
        .onChange(of: routingState.tabSelection, initial: true) { _, destination in
            selectedTab = destination
        }
        .onChange(of: routingState.isTabbarHidden, initial: true) { _, value in
            isTabbarHidden = value
        }
    }
}

// MARK: - Routable

extension ContentView {
    struct Routing: Equatable {
        var tabSelection: Int = SRConstant.mainTab
        var isTabbarHidden: Bool = false
    }
    
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.contentView)
    }
    
    var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.contentView)
    }
}

#Preview {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    appDelegate.rootView
}
