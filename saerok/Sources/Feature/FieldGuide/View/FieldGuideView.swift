//
//  FieldGuideView 2.swift
//  saerok
//
//  Created by HanSeung on 12/9/25.
//


import Combine
import SwiftData
import SwiftUI

enum FieldGuideRoute: AppRoute {
    case search
    case birdDetail(Local.Bird)
    case addSaerok(Local.Bird)
}

struct FieldGuideView: View {
    typealias Route = FieldGuideRoute

    @EnvironmentObject private var coordinator: AppCoordinator
    @Bindable private var viewModel: ViewModel

    @State var showPopup: Bool = false
    @State var offsetY: CGFloat = 0
    @State private var scrollToTopTrigger = false
    
    @State var showSeasonSheet = false
    @State var showHabitatSheet = false
    @State var showSizeSheet = false
    
    // MARK: - Init

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        content
            .query(key: viewModel.filterKey, results: $viewModel.fieldGuide) { filterKey in
                Query(
                    filter: filterKey.build(),
                    sort: \Local.Bird.name
                )
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .search:
                    FieldGuideSearchView(viewModel: coordinator.makeFieldGuideSearchViewModel())
                case .birdDetail(let bird):
                    BirdDetailView(viewModel: coordinator.makeBirdDetailViewModel(bird: bird))
                case .addSaerok(let bird):
                    CollectionFormView(viewModel: coordinator.makeCollectionFormViewModel(mode: .add, bird: bird))
                }
            }
            .onChange(of: viewModel.output) { _, output in
                guard let output = output else { return }

                switch output {
                case .showBirdDetail(let bird):
                    coordinator.push(Route.birdDetail(bird))
                case .scrollToTop:
                    scrollToTopTrigger.toggle()
                }
            }
            .onPreferenceChange(ScrollPreferenceKey.self) { offsetY = $0 }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.fieldGuideState {
        case .notRequested:
            defaultView
        case .loading:
            loadingView
        case .success:
            loadedView
        case let .failure(error):
            failedView(error)
        }
    }
}

// MARK: - Loaded Content
private extension FieldGuideView {
    enum Constants {
        static let headerHeight: CGFloat = 100
        static let headerTopPadding: CGFloat = 16
        static let navBarSpacerHeight: CGFloat = 64
        static let scrollableID: String = "scrollable"
    }

    var loadedView: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.srWhite

            LinearGradient.srGradient
                .opacity(opacityForScroll(offset: offsetY))

            VStack(spacing: 0) {
                Color.clear
                    .frame(height: Constants.navBarSpacerHeight)
                navigationBar
                scrollableContent
            }

            scrollToTopButton
        }
        .ignoresSafeArea(.all)
        .customPopup(
            isPresented: $showPopup,
            config: showPopup ? loginRequiredPopupConfig : nil
        )
    }

    var navigationBar: some View {
        NavigationBar(
            leading: {
                Text("도감")
                    .font(.SRFontSet.headline1)
            },
            trailing: {
                HStack(spacing: 7) {
                    bookmarkButton
                    searchButton
                }
            },
            backgroundColor: .clear
        )
    }

    var bookmarkButton: some View {
        Button(action: viewModel.bookmarkTapped) {
            (viewModel.filterKey.isBookmarked
             ? Image.SRIconSet.bookmarkFilled
             : Image.SRIconSet.bookmark)
            .frame(.defaultIconSizeLarge,
                   tintColor: viewModel.filterKey.isBookmarked ? .pointtext : .black)
        }
        .srStyled(.iconButton)
    }

    var searchButton: some View {
        Button(action: { coordinator.push(Route.search) }) {
            Image.SRIconSet.search
                .frame(.defaultIconSizeLarge)
        }
        .srStyled(.iconButton)
    }

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            Text("\(viewModel.fieldGuide.count)")
                .font(.SRFontSet.heavy)
                .fontWeight(.semibold)
                .foregroundStyle(.splash)
            Text("종의 새가 도감에 등록되어 있어요.")
                .font(.SRFontSet.caption1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: Constants.headerHeight)
        .padding(SRDesignConstant.defaultPadding)
    }

    var scrollableContent: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 0) {
                    OffsetReaderView().id(Constants.scrollableID)
                    headerSection
                    filterBar
                    BirdGridView(
                        birds: viewModel.fieldGuide,
                        onTap: { bird in
                            coordinator.push(Route.birdDetail(bird))
                        },
                        onBookmarkTap: viewModel.toggleBookmark,
                        showPopup: $showPopup
                    )
                }
            }
            .onChange(of: scrollToTopTrigger) { _, _ in
                withAnimation { proxy.scrollTo(Constants.scrollableID, anchor: .top) }
            }
        }
    }

    var filterBar: some View {
        FilterBar(
            showSeasonSheet: $showSeasonSheet,
            showHabitatSheet: $showHabitatSheet,
            showSizeSheet: $showSizeSheet,
            filterKey: $viewModel.filterKey
        )
        .padding(.vertical, Constants.headerTopPadding)
        .background(.srLightGray)
    }

    var scrollToTopButton: some View {
        Button { scrollToTopTrigger.toggle() } label: {
            Image.SRIconSet.upper
                .frame(.defaultIconSizeLarge)
        }
        .srStyled(.iconButton)
        .padding(.bottom, 114)
        .padding(.horizontal, SRDesignConstant.defaultPadding)
        .opacity(offsetY > 0 ? 0 : 1)
    }

    var loginRequiredPopupConfig: PopupConfig {
        PopupConfig(
            title: "로그인이 필요한 기능이에요",
            message: "로그인하고 더 많은 기능을 사용해보세요!",
            buttons: .double(
                .init(
                    title: "취소",
                    style: .bordered,
                    action: {
                        showPopup = false
                    }
                ),
                .init(
                    title: "로그인",
                    style: .confirm,
                    action: {
                        showPopup = false
                        viewModel.navigateToLoginView()
                    }
                )
            )
        )
    }
}

// MARK: - Loading Content

private extension FieldGuideView {
    var defaultView: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.srWhite

            LinearGradient.srGradient
                .opacity(opacityForScroll(offset: offsetY))

            VStack(spacing: 0) {
                Color.clear.frame(height: Constants.navBarSpacerHeight)
                navigationBar
                Spacer()
            }
        }
        .ignoresSafeArea(.all)
        .onAppear { viewModel.loadFieldGuide() }
    }

    var loadingView: some View {
        ProgressView().progressViewStyle(CircularProgressViewStyle())
    }

    func failedView(_ error: Error) -> some View {
        ProgressView().progressViewStyle(CircularProgressViewStyle())
    }
}
