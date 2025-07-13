//
//  MapView.swift
//  saerok
//
//  Created by HanSeung on 5/22/25.
//

import SwiftUI
import SwiftData

struct MapView: View {
    enum Route: Hashable {
        case detail(_ collectionID: Int)
    }
    
    enum Mode {
        case idle, searching, resultShown
    }
    
    // MARK: - Dependencies
    
    @Environment(\.injected) var injected
    private var isGuest: Bool { injected.appState[\.authStatus] == .guest }
    
    // MARK: - View State
    
    private var locationManager: LocationManager { LocationManager.shared }
    @StateObject private var mapController: MapController
    
    @State private var mapViewState: Loadable<Void>
    @State private var position: (Double, Double) = (37.59080, 127.0278)
    @State private var text: String = ""
    @State private var response: [Local.KakaoPlace] = []
    @State private var mode: Mode = .idle
    @FocusState private var isFocused: Bool
    @State private var isMineOnly: Bool = false
    @State private var item: [Local.NearbyCollectionSummary] = []
    @State private var searchDebounceTask: Task<Void, Never>? = nil
    
    @Binding private var path: NavigationPath
    
    private var isModeIdle: Bool { mode == .idle }
    private var networkService: SRNetworkService { injected.networkService }
    
    init(state: Loadable<Void> = .notRequested, path: Binding<NavigationPath>) {
        self._mapViewState = .init(initialValue: state)
        self._path = path
        
        let mapController = MapController(locationManager: LocationManager.shared)
        
        self._mapController = .init(wrappedValue: mapController)
    }
    
    // MARK: - Body
    
    var body: some View {
        content
            .ignoresSafeArea(.all)
            .onAppear {
                mapController.selectedBird = nil
            }
            .navigationDestination(for: MapView.Route.self) { route in
                switch route  {
                case .detail(let id):
                    CollectionDetailView(collectionID: id, path: $path, isFromMap: true)
                }
            }
            .onChange(of: mapController.selectedBird) { _, newBird in
                if let newBird = newBird {
                    path.append(MapView.Route.detail(newBird.collectionId))
                }
            }
    }
    
    // MARK: - Content
    
    @ViewBuilder
    var content: some View {
        switch mapViewState {
        case .notRequested:
            Text("")
            .task {
                if let location = await locationManager.requestAndGetCurrentLocation()?.coordinate {
                    Task {
                        position = (location.latitude, location.longitude)
                        try? await fetchNearby()
                        mapViewState = .loaded(())
                    }
                } else {
                    mapViewState = .loaded(())
                }
            }
        case .loaded:
            ZStack(alignment: .top) {
                resultSection
                searchBarSection
                buttonSection
            }
        default: Text("")
        }
    }
}

// MARK: - Subviews

private extension MapView {
    var searchBarSection: some View {
        VStack(spacing: 14) {
            Color.clear.frame(height: 60)
            SearchInputBar(
                isModeIdle: isModeIdle,
                text: $text,
                isFocused: $isFocused,
                mode: $mode,
                onTap: {
                    mode = .searching
                },
                onTextChange: { new in
                    searchDebounceTask?.cancel()
                    searchDebounceTask = Task {
                        try? await Task.sleep(nanoseconds: 800_000_000) 
                        if !Task.isCancelled && !new.isEmpty {
                            await performSearch()
                        }
                    }
                    mode = (new.isEmpty ? .searching : (mode == .idle ? .idle : mode))
                }
            )
            
            SearchRefreshButton {
                refreshButtonTapped()
            }
            .opacity(mode == .idle ? 1 : 0)
            .allowsHitTesting(mode == .idle)
        }
    }
    
    var resultSection: some View {
        ZStack(alignment: .top) {
            searchResultSection()
                .opacity(!isModeIdle ? 1 : 0)
                .allowsHitTesting(!isModeIdle)
            
            NaverMapView(showCenter: false, coord: $position, controller: mapController)
                .opacity(isModeIdle ? 1 : 0)
                .allowsHitTesting(isModeIdle)
        }
        .onTapGesture { isFocused = false }
    }
    
    var buttonSection: some View {
        VStack {
            Spacer()
            HStack {
                Button {
                    mapController.moveToUserLocation()
                } label: {
                    Image(.mylocation)
                        .resizable()
                        .frame(width: 42, height: 42)
                }
                Spacer()
                
                if !isGuest {
                    GlobalToggleButton(isOff: $isMineOnly) {
                        globalToggleButtonTapped()
                    }
                }
            }
        }
        .padding(SRDesignConstant.defaultPadding)
        .padding(.bottom, 90)
        .opacity(isModeIdle ? 1 : 0)
    }
    
    func searchResultSection() -> some View {
        ScrollView {
            Color.clear.frame(height: 140)
            VStack(spacing: 2) {
                Divider()
                ForEach(response, id: \.id) { item in
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
            searchCellTapped(item)
        }
    }
    
    func searchCellTapped(_ item: Local.KakaoPlace) {
        position = (item.latitude, item.longtitude)
        mapController.moveCamera(lat: item.latitude, lng: item.longtitude)
        mode = .idle
    }
    
    func globalToggleButtonTapped() {
        Task {
            do {
                HapticManager.shared.trigger(.light)
                isMineOnly.toggle()
                try await fetchNearby()
                HapticManager.shared.trigger(.success)
            } catch {
                isMineOnly.toggle()
                HapticManager.shared.trigger(.error)
            }
        }
    }
    
    func refreshButtonTapped() {
        Task {
            HapticManager.shared.trigger(.light)
            try? await fetchNearby()
            HapticManager.shared.trigger(.success)
        }
    }
    
    func fetchNearby() async throws {
        clearMarkers()
        item = try await  injected.interactors.collection.fetchNearbyCollections(
            lat: position.0,
            lng: position.1,
            rad: 5000,
            isMineOnly: isMineOnly,
            isGuest: isGuest
        )
        loadMarkers(item)
    }
    
    func clearMarkers() {
        mapController.clearMarkers()
    }
    
    func loadMarkers(_ items: [Local.NearbyCollectionSummary]) {
        mapController.refreshBirdMarkers(items)
    }
    
    private func performSearch() async {
        do {
            let searchResponse: DTO.KakaoSearchResponse = try await networkService.performKakaoRequest(.keyword(text))
            response = searchResponse.documents.toLocal()
            mode = .resultShown
        } catch {
            // Handle error silently or add error state if needed
        }
    }
    
    struct SearchInputBar: View {
        let isModeIdle: Bool
        @Binding var text: String
        @FocusState.Binding var isFocused: Bool
        @Binding var mode: Mode
        let onTap: () -> Void
        let onTextChange: (String) -> Void
        
        var body: some View {
            HStack {
                Button {
                    mode = .idle
                } label: {
                    isModeIdle ? Image.SRIconSet.searchSecondary.frame(.defaultIconSize) :
                    Image.SRIconSet.chevronLeft.frame(.defaultIconSize)
                }
                TextField("원하는 장소를 입력하세요", text: $text)
                // Removed the '검색' button as per instructions
            }
            .frame(height: 44)
            .padding(.leading, 14)
            .textFieldDeletable(text: $text)
            .srStyled(.textField(isFocused: $isFocused, alwaysFocused: true))
            .padding(.horizontal, SRDesignConstant.defaultPadding)
            .onTapGesture { onTap() }
            .onChange(of: text) { _, new in
                onTextChange(new)
            }
        }
    }
    
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
            withAnimation(.bouncy(duration: 0.4)) {
                buttonAction()
            }
        }) {
            ZStack(alignment: isOff ? .leading : .trailing) {
                RoundedRectangle(cornerRadius: .infinity)
                    .fill(isOff ? Color.lightGray : Color.main)
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

#Preview {
    @Previewable @State var path = NavigationPath()
    MapView(path: $path)
}
