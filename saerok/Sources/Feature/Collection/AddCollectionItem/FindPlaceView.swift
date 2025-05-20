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
    
    // MARK: View State
    
    @State private var mode: Mode = .idle

    @Binding var selectedPosition: (Double, Double)
    @State private var text: String = ""
    @State private var response: [Local.KakaoPlace] = []

    @FocusState private var isFocused: Bool
    
    @StateObject private var mapController = MapController()
    
    private var networkService: SRNetworkService { injected.networkService }

    // MARK: Navigation
    
    @Binding var path: NavigationPath
        
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            searchBarSection
            resultSection
        }
        .onAppear {
            mapController.moveToUserLocation()
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
        HStack {
            TextField("장소를 입력해주세요", text: $text)
            Button {
                Task {
                    response = try await networkService.fetchLocalSearchResult(endpoint: .keyword(text))
                        .documents
                        .toLocal()
                    mode = .resultShown
                }
            } label: {
                Text("검색")
                    .padding(.trailing, 30)
            }
        }
        .textFieldDeletable(text: $text)
        .padding(.vertical, 14)
        .padding(.leading, 18)
        .frame(height: 44)
        .srStyled(.textField(isFocused: $isFocused))
        .padding(.horizontal, SRDesignConstant.defaultPadding)
        .padding(.bottom, 14)
        .onTapGesture {
            mode = .searching
        }
        .onChange(of: text) { _, new in
            if new.isEmpty && mode == .searching {
                mode = .searching
            } else if !new.isEmpty && mode == .idle {
                mode = .idle
            } else {
                
            }
        }
    }
    
    var resultSection: some View {
        ZStack {
            searchResultSection()
                .opacity(mode != .idle ? 1 : 0)
                .allowsHitTesting(mode != .idle)

            ZStack(alignment: .bottom) {
                MapView(coord: $selectedPosition, controller: mapController)
                Button {
                    path.removeLast()
                    injected.appState[\.routing.addCollectionItemView.locationSelected] = true
                } label: {
                    Text("이 위치로 입력할게요")
                        .font(.SRFontSet.body1)
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
                            selectedPosition = (item.latitude, item.longtitude)
                            mapController.moveCamera(lat: item.latitude, lng: item.longtitude)
                            text = item.placeName
                            mode = .idle
                        }
                    }
                }
            }
        }
        .background(Color.whiteGray)
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
}

#Preview {
    @Previewable @State var path = NavigationPath()
    @Previewable @State var coord = (0.0,0.0)
    FindPlaceView(selectedPosition: $coord, path: $path)
}
