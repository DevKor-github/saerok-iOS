//
//  MapView.swift
//  saerok
//
//  Created by HanSeung on 5/22/25.
//

import SwiftUI

enum MapRoute: AppRoute {
    case detail(_ collectionID: Int)
}

struct MapView: View {
    typealias Route = MapRoute
    
    // MARK: - Dependencies
    @EnvironmentObject private var coordinator: AppCoordinator
    @Environment(\.showToast) private var showToast

    @State private var viewModel: ViewModel
    @FocusState private var isFocused: Bool

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
        
    var body: some View {
        content
            .ignoresSafeArea(.all)
            .onAppear {
                Task {
                    viewModel.onAppear()
                    await viewModel.initialLoad()
                }
            }
            .navigationDestination(for: Route.self) { route in
                switch route  {
                case .detail(let id):
                    CollectionDetailView(viewModel: coordinator.factory.makeCollectionDetailViewModel(id: id, entrySource: .map, screen: .map))
                }
            }
            .onChange(of: viewModel.mapController.selectedBird) { _, newBird in
                if let newBird = newBird {
                    coordinator.push(MapRoute.detail(newBird.collectionId))
                }
            }
            .onChange(of: viewModel.output, initial: true) { _, output in
                guard let output else { return }
                
                switch output {
                case .navigateTo(coord: let coord):
                    viewModel.handleRoutingNavigationUpdate(coord)
                case .showToast(let message):
                    showToast(
                        .init(
                            type: .normal,
                            message: message,
                            placementOffset: -120,
                            transitionOffset: 160,
                            duration: 2.0
                        )
                    )
                }
                viewModel.resetOutput()
            }
    }
        
    @ViewBuilder
    var content: some View {
        switch viewModel.mapViewState {
        case .notRequested, .loading:
            ProgressView()
        case .success:
            loadedContent
        case .failure:
            locationPermissionDeniedView
        }
    }
}

// MARK: - Subviews

private extension MapView {
    var locationPermissionDeniedView: some View {
        VStack(spacing: 16) {
            Image.SRIconSet.pin
                .frame(.large)
                .foregroundStyle(.srGray)
            VStack(spacing: 6) {
                Text("위치 접근이 필요해요")
                    .font(.SRFontSet.subtitle1_2)
                Text("설정에서 위치 권한을 허용하면\n주변 새록을 지도에서 볼 수 있어요")
                    .font(.SRFontSet.body2)
                    .foregroundStyle(.srDarkGray)
                    .multilineTextAlignment(.center)
            }
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("설정 열기")
                    .font(.SRFontSet.body2)
                    .frame(width: 120)
            }
            .srStyled(.primaryButton)
            .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.srWhite)
    }

    var loadedContent: some View {
        ZStack(alignment: .top) {
            resultSection
            searchBarSection
            buttonSection
            
            if viewModel.isModeIdle {
                Text("")
                    .bottomSheet(alwaysOnDisplay: true, keyboard: KeyboardObserver()) {
                        NearbySheet(address: viewModel.address, item: viewModel.item) { item in
                            coordinator.push(Route.detail(item.collectionId))
                        }
                    }
                    .ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }
    }
    
    var searchBarSection: some View {
        VStack(spacing: 14) {
            Color.clear.frame(height: 60)
            SearchInputBar(
                tintColor: nil,
                placeHolder: "원하는 장소를 입력하세요",
                isModeIdle: viewModel.isModeIdle,
                text: $viewModel.text,
                isFocused: $isFocused,
                mode: $viewModel.mode,
                onTap: {
                    viewModel.mode = .searching
                },
                onTextChange: { new in
                    viewModel.performSearchDebounced()
                    viewModel.mode = (new.isEmpty ? .searching : (viewModel.mode == .idle ? .idle : viewModel.mode))
                }
            )
            .equatable()

            SearchRefreshButton {
                viewModel.refreshButtonTapped()
                viewModel.reloadAddress()
            }
            .opacity(viewModel.mode == .idle ? 1 : 0)
            .allowsHitTesting(viewModel.mode == .idle)
        }
        .onChange(of: isFocused) { _, new in
            if new {
                viewModel.mode = .searching
            }
        }
        .onChange(of: viewModel.mode) { _, new in
            if new == .idle {
                isFocused = false
            }
        }
    }
    
    var resultSection: some View {
        ZStack(alignment: .top) {
            searchResultSection()
                .opacity(!viewModel.isModeIdle ? 1 : 0)
                .allowsHitTesting(!viewModel.isModeIdle)
            
            NaverMapView(showCenter: false, coord: $viewModel.position, controller: viewModel.mapController)
                .opacity(viewModel.isModeIdle ? 1 : 0)
                .allowsHitTesting(viewModel.isModeIdle)
        }
        .onTapGesture { isFocused = false }
    }
    
    var buttonSection: some View {
        VStack {
            Spacer()
            HStack {
                Button {
                    viewModel.mapController.moveToUserLocation()
                } label: {
                    Image(.mylocation)
                        .resizable()
                        .frame(width: 48, height: 48)
                }
                Spacer()
                
                if !viewModel.isGuest {
                    GlobalToggleButton(isOff: $viewModel.isMineOnly) {
                        viewModel.globalToggleButtonTapped()
                    }
                }
            }
        }
        .padding(SRDesignConstant.defaultPadding)
        .padding(.bottom, 152)
        .opacity(viewModel.isModeIdle ? 1 : 0)
    }
    
    func searchResultSection() -> some View {
        ScrollView {
            Color.clear.frame(height: 140)
            VStack(spacing: 2) {
                Divider()
                ForEach(viewModel.response, id: \.id) { item in
                    VStack(spacing: 0) {
                        searchCell(item)
                        Divider()
                    }
                    .listRowInsets(.init())
                }
            }
        }
        .background(Color.srWhite)
    }
    
    func searchCell(_ item: Local.KakaoPlace) -> some View {
        HStack(spacing: 15) {
            Image.SRIconSet.pin.frame(.large)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.placeName)
                    .font(.SRFontSet.body3_2)
                Text(item.address.isEmpty ? item.roadAddress : item.address)
                    .font(.SRFontSet.caption1)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image.SRIconSet.chevronRight
                .frame(.small)
                .foregroundStyle(.black)
        }
        .padding(SRDesignConstant.defaultPadding)
        .frame(height: 68)
        .frame(maxWidth: .infinity)
        .background(Color.srWhite)
        .onTapGesture {
            viewModel.searchCellTapped(item)
        }
    }
}

// MARK: - SearchBar

struct SearchInputBar: View, Equatable {
    enum Mode: Equatable {
        case idle, searching, resultShown
    }

    let tintColor: Color?
    let placeHolder: String
    let isModeIdle: Bool
    @Binding var text: String
    @FocusState.Binding var isFocused: Bool
    @Binding var mode: Mode
    let onTap: () -> Void
    let onTextChange: (String) -> Void

    // 클로저는 비교 불가(참조 타입 캡처라 stale 위험 없음)와 바인딩은 제외.
    // 화면에 보이는 값만 비교해 부모 재평가 시 불필요한 재구성을 차단한다.
    static func == (lhs: SearchInputBar, rhs: SearchInputBar) -> Bool {
        lhs.tintColor == rhs.tintColor &&
        lhs.placeHolder == rhs.placeHolder &&
        lhs.isModeIdle == rhs.isModeIdle &&
        lhs.text == rhs.text
    }
    
    var body: some View {
        HStack {
            Button {
                text = ""
                if mode == .idle {
                    mode = .searching
                } else {
                    mode = .idle
                }
            } label: {
                (isModeIdle
                 ? Image.SRIconSet.searchSecondary
                 : Image.SRIconSet.chevronLeft)
                .frame(.default, tintColor: tintColor)
            }
            TextField(placeHolder, text: $text)
                .onTapGesture { onTap() }
        }
        .frame(height: 44)
        .padding(.leading, 14)
        .textFieldDeletable(text: $text)
        .srStyled(.textField(isFocused: $isFocused, alwaysFocused: true, tintColor: tintColor))
        .padding(.horizontal, SRDesignConstant.defaultPadding)
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
        .onChange(of: text) { _, new in
            onTextChange(new)
        }
    }
}

extension MapView {
    struct SearchRefreshButton: View {
        let onTap: () -> Void
        
        var body: some View {
            Button {
                onTap()
            } label: {
                HStack {
                    Image.SRIconSet.reset
                        .frame(.default)
                        .foregroundStyle(.splash)
                    Text("이 지역 재검색하기")
                        .font(.SRFontSet.body2)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.srWhite)
                .cornerRadius(.infinity)
                .shadow(radius: 2)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Global Toggle Button
private struct GlobalToggleButton: View {
    @Binding var isOff: Bool
    let buttonAction: () -> Void
    
    var body: some View {
        Button(action: {
            buttonAction()
        }) {
            ZStack(alignment: isOff ? .leading : .trailing) {
                RoundedRectangle(cornerRadius: .infinity)
                    .fill(isOff ? Color.srLightGray : Color.main)
                    .frame(width: 72, height: 42)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                
                Circle()
                    .fill(isOff ? Color.clear : .splash)
                    .frame(width: 38, height: 38)
                    .padding(.horizontal, 2)

                Image.SRIconSet.global
                    .frame(.custom(width: 38, height: 38))
                    .padding(.horizontal, 2)
            }
        }
        .buttonStyle(.plain)
    }
}
