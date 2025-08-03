//
//  FindPlaceView.swift
//  saerok
//
//  Created by HanSeung on 5/8/25.
//


import SwiftUI

struct FindPlaceView: View {
    enum Mode {
        case idle
        case searching
        case resultShown
    }
    
    // MARK:  Dependencies
    
    @Environment(\.injected) var injected
    
    // MARK: - View State
    
    @ObservedObject var collectionDraft: Local.CollectionDraft
    @Binding var path: NavigationPath
    
    @State private var mode: Mode = .idle
    @State private var response: [Local.KakaoPlace] = []
    
    @State private var searchText: String = ""
    @State private var showingSheet: Bool = false
    @FocusState private var isFocused: Bool
    
    @StateObject private var mapController: MapController = .init(locationManager: LocationManager.shared)
    
    @State private var searchDebounceTask: Task<Void, Never>?
    
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
                path.removeLast()
            } label: {
                Image.SRIconSet.chevronLeft.frame(.defaultIconSizeSmall)
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
            .onTapGesture {
                mode = .searching
            }
            .onChange(of: searchText) { _, new in
            searchDebounceTask?.cancel()
            searchDebounceTask = Task {
                try? await Task.sleep(nanoseconds: 800_000_000)
                if !Task.isCancelled && !new.isEmpty {
                    await performSearch()
                } else if new.isEmpty {
                    await MainActor.run {
                        mode = .idle
                        response = []
                    }
                }
            }
        }
    }
    
    var resultSection: some View {
        ZStack {
            searchResultSection()
                .opacity(mode != .idle ? 1 : 0)
                .allowsHitTesting(mode != .idle)

            ZStack(alignment: .bottom) {
                NaverMapView(coord: $collectionDraft.coordinate, controller: mapController)
                Button {
                    selectButtonTapped()
                } label: {
                    Text("이 위치로 입력할게요")
                        .font(.SRFontSet.button1)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.primary)
                .padding(SRDesignConstant.defaultPadding)
            }
            .opacity(mode == .idle ? 1 : 0)
            .allowsHitTesting(mode == .idle)
        }
        .onTapGesture {
            isFocused = false
        }
    }
    
    func performSearch() async {
        do {
            let searchResponse: DTO.KakaoSearchResponse = try await networkService.performKakaoRequest(.keyword(searchText))
            await MainActor.run {
                response = searchResponse.documents.toLocal()
                mode = .resultShown
            }
        } catch {
            // Handle error (optional)
        }
    }
    
    func searchResultSection() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Color.clear
                    .frame(height: 4)
                
                VStack(spacing: 2) {
                    ForEach(response, id: \.id) { item in
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
            Image.SRIconSet.pin.frame(.defaultIconSizeLarge)
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
        collectionDraft.coordinate = (item.latitude, item.longtitude)
        mapController.moveCamera(lat: item.latitude, lng: item.longtitude)
        mode = .idle
    }
    
    func submitButtonTapped() {
        injected.appState[\.routing.addCollectionItemView.locationSelected] = true
        showingSheet = false
        path.removeLast()
    }
    
    func selectButtonTapped() {
        Task {
            await requestAddress()
            showingSheet.toggle()
        }
    }
    
    func requestAddress() async {
        do {
            let result: DTO.KakaoAddressResponse = try await networkService.performKakaoRequest(
                .address(
                    lng: collectionDraft.coordinate.0,
                    lat: collectionDraft.coordinate.1
                )
            )
            let place = result.documents.toLocal().first
            
            if let roadAddress = place?.roadAddress {
                self.collectionDraft.address = roadAddress
            } else if let address = place?.address {
                self.collectionDraft.address = address
            } else {
                collectionDraft.address = "주소를 찾을 수 없음"
            }
        } catch {
            collectionDraft.address = "주소를 찾을 수 없음"
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
                    Text(placeAddress)
                        .font(.SRFontSet.caption1)
                        .foregroundStyle(.secondary)
                        .padding(.leading, SRDesignConstant.defaultPadding / 2)
                
                Spacer()
                
                Button("발견 장소 등록", action: buttonAction)
                    .font(.SRFontSet.button1)
                    .buttonStyle(.primary)
                    .frame(height: 53)
            }
            .padding(SRDesignConstant.defaultPadding)
        }
    }
}

#Preview {
    @Previewable @State var draft = Local.CollectionDraft(collectionID: 1)
    @Previewable @State var path: NavigationPath = .init()
    FindPlaceView(collectionDraft: draft, path: $path)
}
