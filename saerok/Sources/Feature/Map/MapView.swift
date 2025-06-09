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
    
    // MARK: - View State
    
    @State private var mapViewState: Loadable<Void>
    @StateObject private var mapController = MapController()
    @State private var position: (Double, Double) = (37.59080, 127.0278)
    @State private var text: String = ""
    @State private var response: [Local.KakaoPlace] = []
    @State private var mode: Mode = .idle
    @FocusState private var isFocused: Bool
    @State private var isGlobalOn: Bool = true
    @State private var item: [Local.CollectionDetail] = []
    
    @Binding private var path: NavigationPath
    
    private var isModeIdle: Bool { mode == .idle }
    private var networkService: SRNetworkService { injected.networkService }
    
    init(state: Loadable<Void> = .notRequested, path: Binding<NavigationPath>) {
        self._mapViewState = .init(initialValue: state)
        self._path = path
    }
    
    // MARK: - Body
    
    var body: some View {
        content
            .ignoresSafeArea(.all)
            .onAppear {
                mapController.selectedBird = nil
//                item = injected.interactors.collection.fetchMyCollections()
            }
            .navigationDestination(for: MapView.Route.self) { route in
                switch route  {
                case .detail(let id):
                    CollectionDetailView(collectionID: id, path: $path, isFromMap: true)
                }
            }
            .onChange(of: mapController.selectedBird) { _, newBird in
                if let newBird = newBird {
                    path.append(MapView.Route.detail(newBird.id))
                }
            }
    }
    
    // MARK: - Content
    
    @ViewBuilder
    var content: some View {
        switch mapViewState {
        case .notRequested:
            Text("")
                .onAppear {
                    loadMarkers()
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
    
    func loadMarkers() {
        $mapViewState.load {
            mapController.refreshBirdMarkers(item)
        }
    }
}

// MARK: - Subviews

private extension MapView {
    var searchBarSection: some View {
        VStack {
            Color.clear.frame(height: 60)
            HStack {
                Button {
                    mode = .idle
                } label: {
                    isModeIdle ? Image.SRIconSet.searchSecondary.frame(.defaultIconSize) :
                    Image.SRIconSet.chevronLeft.frame(.defaultIconSize)
                }
                TextField("원하는 장소를 입력하세요", text: $text)
                Button("검색") {
                    Task {
                        let searchResponse: DTO.KakaoSearchResponse = try await networkService.performKakaoRequest(.keyword(text))
                        response = searchResponse.documents.toLocal()
                        mode = .resultShown
                    }
                }
                .padding(.trailing, 30)
            }
            .frame(height: 44)
            .padding(.leading, 14)
            .textFieldDeletable(text: $text)
            .srStyled(.textField(isFocused: $isFocused, alwaysFocused: true))
            .padding(.horizontal, SRDesignConstant.defaultPadding)
            .onTapGesture { mode = .searching }
            .onChange(of: text) { _, new in
                mode = (new.isEmpty ? .searching : (mode == .idle ? .idle : mode))
            }
        }
    }
    
    var resultSection: some View {
        ZStack {
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
                GlobalToggleButton(isOn: $isGlobalOn)
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
                    .font(.SRFontSet.body3)
                Text(item.address.isEmpty ? item.roadAddress : item.address)
                    .font(.SRFontSet.caption1)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack {
                Text(item.category)
                    .font(.SRFontSet.caption1)
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .padding(SRDesignConstant.defaultPadding)
        .frame(maxWidth: .infinity)
        .background(Color.srWhite)
        .onTapGesture {
            searchCellTapped(item)
        }
    }
    
    func searchCellTapped(_ item: Local.KakaoPlace) {
        position = (item.latitude, item.longtitude)
        mapController.moveCamera(lat: item.latitude, lng: item.longtitude)
        text = item.placeName
        mode = .idle
    }
}

// MARK: - Global Toggle Button

private struct GlobalToggleButton: View {
    @Binding var isOn: Bool
    
    var body: some View {
        Button(action: {
            withAnimation(.bouncy(duration: 0.4)) {
                isOn.toggle()
            }
        }) {
            ZStack(alignment: isOn ? .trailing : .leading) {
                RoundedRectangle(cornerRadius: .infinity)
                    .fill(isOn ? Color.main : Color.whiteGray)
                    .frame(width: 72, height: 42)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                
                Circle()
                    .fill(isOn ? Color.splash : .clear)
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
