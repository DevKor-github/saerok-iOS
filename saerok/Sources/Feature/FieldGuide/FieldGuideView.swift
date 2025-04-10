//
//  FieldGuideView.swift
//  saerok
//
//  Created by HanSeung on 4/8/25.
//


import Combine
import SwiftData
import SwiftUI

struct FieldGuideView: Routable {
    
    // MARK:  Dependencies
    
    @Environment(\.injected) private var injected: DIContainer
    
    // MARK:  Routable
    
    @State var routingState: Routing = .init()
    
    // MARK: Navigation
    
    @State internal var navigationPath = NavigationPath()
    
    // MARK: View State
    
    @State private var fieldGuide: [Local.Bird]
    @State private var fieldGuideState: Loadable<Void>
    @State private var searchText: String = ""
    @State private var isAllBookmarked: Bool = false
    
    // MARK:  Init
    
    init(state: Loadable<Void> = .notRequested) {
        self.fieldGuide = []
        self._fieldGuideState = .init(initialValue: state)
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            content
                .query(searchText: searchText, results: $fieldGuide, { search in
                    Query(
                        filter: #Predicate<Local.Bird> { bird in
                            if search.isEmpty {
                                return true
                            } else {
                                return bird.name.localizedStandardContains(search)
                            }
                        },
                        sort: \Local.Bird.name)
                })
                .query(searchText: isAllBookmarked ? "Bookmark" : "", results: $fieldGuide, { search in
                    Query(
                        filter: #Predicate<Local.Bird> { bird in
                            if search.isEmpty {
                                return true
                            } else {
                                return bird.isBookmarked
                            }
                        },
                        sort: \Local.Bird.name)
                })
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
            HStack(spacing: 16) {
                Text("도감")
                    .font(.SRFontSet.h1)
                Spacer()
                
                Group {
                    Button {
                        isAllBookmarked.toggle()
                        
                    } label: {
                        Image(isAllBookmarked ? .bookmarkFill : .bookmark)
                            .foregroundStyle(isAllBookmarked ? .main : .black)
                    }
                    Button {
                        
                    } label: {
                        Image(.magnifyingglass)
                    }
                }
                .font(.system(size: 24))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, SRDesignConstant.defaultPadding)
            .padding(.vertical, 17)
            
            if fieldGuide.isEmpty {
                Text("No matches found")
                    .font(.SRFontSet.h3)
                    .frame(maxHeight: .infinity)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 15),
                            GridItem(.flexible(), spacing: 15)
                        ],
                        spacing: 15
                    ) {
                        ForEach(fieldGuide) { bird in
                            NavigationLink(value: bird) {
                                BirdCardView(bird)
                            }
                            .buttonStyle(.plain)
                        }
                        Rectangle()
                            .foregroundStyle(.clear)
                            .frame(height: 80)
                        Rectangle()
                            .foregroundStyle(.clear)
                            .frame(height: 80)
                    }
                    .padding(SRDesignConstant.defaultPadding)
                }
                .background(Color.background)
                .navigationDestination(for: Local.Bird.self, destination: { bird in
                    Text(bird.name)
                        .onAppear {
                            injected.appState[\.routing.contentView.isTabbarHidden] = true
                        }
                })
                .onAppear {
                    injected.appState[\.routing.contentView.isTabbarHidden] = false
                }
                .onChange(of: routingState.birdName, initial: true, { _, name in
                    guard let name,
                          let bird = fieldGuide.first(where: { $0.name == name })
                    else { return }
                    navigationPath.append(bird)
                })
                .onChange(of: navigationPath, { _, path in
                    if !path.isEmpty {
                        routingBinding.wrappedValue.birdName = nil
                    }
                })
            }
        }
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
