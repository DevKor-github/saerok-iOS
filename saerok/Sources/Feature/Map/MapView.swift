//
//  MapView.swift
//  saerok
//
//  Created by HanSeung on 5/22/25.
//

import Combine
import SwiftUI
import SwiftData
import Foundation

enum MapRoute: AppRoute {
    case detail(_ collectionID: Int)
}

struct MapView: View {
    typealias Route = MapRoute
    
    // MARK: - Dependencies
    @EnvironmentObject private var coordinator: AppCoordinator
        
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
                    CollectionDetailView(viewModel: coordinator.makeCollectionDetailViewModel(id: id))
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
                }
                viewModel.resetOutput()
            }
    }
        
    @ViewBuilder
    var content: some View {
        switch viewModel.mapViewState {
        case .notRequested:
            Text("")
        case .success:
            loadedContent
        default:
            Text("")
        }
    }
}

// MARK: - Subviews

private extension MapView {
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
                    viewModel.debounceTask {
                        await viewModel.performSearch()
                    }
                    viewModel.mode = (new.isEmpty ? .searching : (viewModel.mode == .idle ? .idle : viewModel.mode))
                }
            )
            
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
            Image.SRIconSet.pin.frame(.defaultIconSizeLarge)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.placeName)
                    .font(.SRFontSet.body3_2)
                Text(item.address.isEmpty ? item.roadAddress : item.address)
                    .font(.SRFontSet.caption1)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image.SRIconSet.chevronRight
                .frame(.defaultIconSizeSmall)
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

struct SearchInputBar: View {
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
                .frame(.defaultIconSize, tintColor: tintColor)
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
                        .frame(.defaultIconSize)
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
