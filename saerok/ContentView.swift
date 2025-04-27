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
    
    @State private var showSplash = true
    @State var selectedTab: TabbedItems = SRConstant.mainTab
    @State var isTabbarHidden: Bool = false
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .srWhite
        appearance.shadowColor = .clear
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
//    var body: some View {
//        if showMain {
//            NavigationStack {
//                ZStack(alignment: .bottom) {
//                    switch selectedTab {
//                    case .fieldGuide:
//                        FieldGuideView()
//                    case .collection:
//                        CollectionView()
//                    default:
//                        Rectangle()
//                            .foregroundStyle(.clear)
//                    }
//
//                    TabbarView(selectedTab: selectedTab)
//                        .opacity(routingState.isTabbarHidden ? 0 : 1)
//                        .allowsHitTesting(!routingState.isTabbarHidden)
//                }
//                .ignoresSafeArea(edges: .bottom)
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .onReceive(routingUpdate) { self.routingState = $0 }
//            .onChange(of: routingState.tabSelection, initial: true) { _, destination in
//                selectedTab = destination
//            }
//            .onChange(of: routingState.isTabbarHidden, initial: true) { _, value in
//                isTabbarHidden = value
//            }
//        } else {
//            LottieView(animationName: "splash", completion: {
//                withAnimation {
//                    showMain = true
//                }
//            })
//            .background(Color.red)
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .ignoresSafeArea()
//        }
//    }
    var body: some View {
            ZStack {
                // 메인 화면
                NavigationStack {
                    ZStack(alignment: .bottom) {
                        switch selectedTab {
                        case .fieldGuide:
                            FieldGuideView()
                        case .collection:
                            CollectionView()
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
                .opacity(showSplash ? 0 : 1)
                .animation(.easeInOut(duration: 0.5), value: showSplash)
                .onReceive(routingUpdate) { self.routingState = $0 }
                .onChange(of: routingState.tabSelection, initial: true) { _, destination in
                    selectedTab = destination
                }
                .onChange(of: routingState.isTabbarHidden, initial: true) { _, value in
                    isTabbarHidden = value
                }
                
                if showSplash {
                    LottieView(animationName: "splash", completion: {
                        withAnimation {
                            showSplash = false
                        }
                    })
                    .background(Color.srWhite)
                    .ignoresSafeArea()
                }
            }
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

#Preview {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    appDelegate.rootView
}
