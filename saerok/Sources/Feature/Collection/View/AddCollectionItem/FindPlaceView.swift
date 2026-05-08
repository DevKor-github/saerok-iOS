//
//  FindPlaceView.swift
//  saerok
//
//  Created by HanSeung on 5/8/25.
//


import SwiftUI

extension FindPlaceView {
    @Observable
    final class ViewModel {
        enum Mode {
            case idle
            case searching
            case resultShown
        }

        private(set) var mode: Mode = .idle
        private(set) var searchResults: [Local.KakaoPlace] = []
        @ObservationIgnored private var searchDebounceTask: Task<Void, Never>?

        func scheduleSearch(text: String, using networkService: SRNetworkService) {
            mode = .searching
            searchDebounceTask = Task.debounce(task: searchDebounceTask) {
                await self.performSearch(text, using: networkService)
            }
        }

        func cancelSearch() {
            searchDebounceTask?.cancel()
            mode = .idle
            searchResults = []
        }

        func requestAddress(lat: Double, lng: Double, using networkService: SRNetworkService) async -> String {
            do {
                let result: DTO.KakaoAddressResponse = try await networkService.performKakaoRequest(
                    .address(lng: lat, lat: lng)
                )
                let place = result.documents.toLocal().first
                if let roadAddress = place?.roadAddress { return roadAddress }
                if let address = place?.address { return address }
            } catch { }
            return "주소를 찾을 수 없음"
        }

        func searchItemSelected(item: Local.KakaoPlace, mapController: MapController, collectionDraft: Local.CollectionDraft) {
            mapController.moveCamera(lat: item.latitude, lng: item.longitude)
            mode = .idle
        }

        private func performSearch(_ text: String, using networkService: SRNetworkService) async {
            do {
                let response: DTO.KakaoSearchResponse = try await networkService.performKakaoRequest(.keyword(text))
                await MainActor.run {
                    searchResults = response.documents.toLocal()
                    mode = .resultShown
                }
            } catch { }
        }
    }
}

struct FindPlaceView: View {
    // MARK:  Dependencies

    @Environment(\.injected) var injected
    @EnvironmentObject private var coordinator: AppCoordinator

    // MARK: - View State

    @Bindable var collectionDraft: Local.CollectionDraft
    @State private var viewModel = ViewModel()
    @State private var searchText: String = ""
    @State private var showingSheet: Bool = false
    @FocusState private var isFocused: Bool
    @State private var mapController: MapController = .init(locationManager: LocationManager.shared)

    private var networkService: SRNetworkService { injected.networkService }
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            searchBarSection
            resultSection
        }
        .sheet(isPresented: $showingSheet) {
            PlaceDetailSheet(address: collectionDraft.address, text: $collectionDraft.locationAlias, submitButtonTapped)
                .presentationDetents([.height(340)])
        }
        .regainSwipeBack()
    }
}

private extension FindPlaceView {
    var navigationBar: some View {
        NavigationBar(center: {
            Text("장소 찾기")
                .font(.SRFontSet.subtitle2)
        }, leading: {
            Button {
                coordinator.pop()
            } label: {
                Image.SRIconSet.chevronLeft.frame(.small)
            }
        })
        .frame(height: 66)
    }
    
    var searchBarSection: some View {
        TextField("장소를 입력해주세요", text: $searchText)
            .padding(.leading, 18)
            .padding(.vertical, 14)
            .frame(height: 44)
            .srStyled(.textField(isFocused: $isFocused))
            .textFieldDeletable(text: $searchText)
            .padding(.horizontal, SRDesignConstant.defaultPadding)
            .padding(.bottom, 20)
            .frame(maxWidth: .infinity)
            .background(Color.srWhite)
            .onChange(of: searchText) { _, new in
                if new.isEmpty {
                    viewModel.cancelSearch()
                } else {
                    viewModel.scheduleSearch(text: new, using: networkService)
                }
            }
    }
    
    var resultSection: some View {
        ZStack {
            searchResultSection()
                .opacity(viewModel.mode != .idle ? 1 : 0)
                .allowsHitTesting(viewModel.mode != .idle)

            ZStack(alignment: .bottom) {
                NaverMapView(coord: $collectionDraft.coordinate, controller: mapController)
                Button {
                    selectButtonTapped()
                } label: {
                    Text("선택하기")
                        .font(.SRFontSet.button1)
                        .frame(maxWidth: .infinity)
                }
                .srStyled(.primaryButton)
                .padding(SRDesignConstant.defaultPadding)
            }
            .opacity(viewModel.mode == .idle ? 1 : 0)
            .allowsHitTesting(viewModel.mode == .idle)
        }
        .onTapGesture {
            isFocused = false
        }
    }

    func searchResultSection() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Color.clear
                    .frame(height: 4)

                VStack(spacing: 2) {
                    ForEach(viewModel.searchResults, id: \.id) { item in
                        searchCell(item)
                            .listRowInsets(.init())
                            .onTapGesture {
                                searchItemTapped(item)
                            }
                    }
                }
            }
        }
        .background(.srLightGray)
    }
    
    func searchCell(_ item: Local.KakaoPlace) -> some View {
        HStack(spacing: 15) {
            Image.SRIconSet.pin.frame(.large)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.placeName)
                    .font(.SRFontSet.body3)
                Text(item.address)
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
    }
    
    func searchItemTapped(_ item: Local.KakaoPlace) {
        collectionDraft.coordinate = (item.latitude, item.longitude)
        mapController.moveCamera(lat: item.latitude, lng: item.longitude)
        viewModel.cancelSearch()
        searchText = ""
    }

    func submitButtonTapped() {
        injected.appState[\.routing.addCollectionItemView.locationSelected] = true
        showingSheet = false
        coordinator.pop()
    }

    func selectButtonTapped() {
        Task {
            collectionDraft.address = await viewModel.requestAddress(
                lat: collectionDraft.coordinate.0,
                lng: collectionDraft.coordinate.1,
                using: networkService
            )
            showingSheet.toggle()
        }
    }
}

// MARK: - Place Detail Sheet

private extension FindPlaceView {
    struct PlaceDetailSheet: View {
        @FocusState private var isFocused: Bool
        @Binding var text: String
        let placeAddress: String
        let buttonAction: () -> Void
        
        init(address: String, text: Binding<String>, _ buttonAction: @escaping () -> Void) {
            self.placeAddress = address
            self._text = text
            self.buttonAction = buttonAction
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 7) {
                Text("어디서 봤냐면요...")
                    .font(.SRFontSet.subtitle1)
                Text("이 장소가 어디인지 소개해주세요!")
                    .font(.SRFontSet.body2)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 27)
                TextField("ex. 난지한강공원, 푸르른 산속 ...", text: $text)
                    .padding(.vertical, 13)
                    .padding(.horizontal, 20)
                    .srStyled(.textField(isFocused: $isFocused))
                    .onChange(of: text) { _, newValue in
                        if newValue.count > 20 {
                            text = String(newValue.prefix(20))
                        }
                    }
                Text(placeAddress)
                    .font(.SRFontSet.caption1)
                    .foregroundStyle(.secondary)
                    .padding(.leading, SRDesignConstant.defaultPadding / 2)
                
                Spacer()
                
                Button("발견 장소 등록", action: {
                    text = text.trimmingCharacters(in: .whitespacesAndNewlines)
                    buttonAction()
                })
                .font(.SRFontSet.button1)
                .srStyled(.primaryButton)
                .frame(height: 53)
                .disabled(text.isEmpty)
            }
            .padding(SRDesignConstant.defaultPadding)
        }
    }
}
