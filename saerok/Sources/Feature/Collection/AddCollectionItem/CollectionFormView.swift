//
//  AddCollectionItemView.swift
//  saerok
//
//  Created by HanSeung on 4/24/25.
//


import Combine
import SwiftUI

struct CollectionFormView: Routable {
    enum Route {
        case findBird
        case findLocation
    }
    
    let mode: CollectionFormMode
    
    // MARK:  Dependencies
    
    @Environment(\.injected) var injected
    @Environment(\.modelContext) var context
    private var networkService: SRNetworkService { injected.networkService }
    
    // MARK:  Routable
    
    @State var routingState: Routing = .init()
    
    // MARK: Navigation
    
    @Binding var path: NavigationPath
    
    // MARK: View State
    
    @State var activePopup: CollectionPopup = .none
    @StateObject var collectionDraft: Local.CollectionDraft
    
    init(mode: CollectionFormMode, path: Binding<NavigationPath>) {
        self.mode = mode
        self._path = path
        switch mode {
        case .add:
            self._collectionDraft = StateObject(wrappedValue: .init(collectionID: nil))
        case .edit(let detail):
            self._collectionDraft = StateObject(wrappedValue: .fromDetail(detail))
        }
    }
    
    var body: some View {
        content
            .onReceive(routingUpdate) { self.routingState = $0 }
            .navigationDestination(for: Route.self, destination: { route in
                switch route {
                case .findBird:
                    CollectionSearchView(path: $path)
                case .findLocation:
                    FindPlaceView(collectionDraft: collectionDraft, path: $path)
                }
            })
            .onChange(of: routingState.selectedBird) { _, selectedBird in
                self.collectionDraft.bird = selectedBird
            }
            .onChange(of: routingState.locationSelected) { _, newValue in
                if newValue {
                    requestAddress()
                }
            }
            .onAppear {
                injected.appState[\.routing.collectionView.addCollection] = false
                loadBirdIfNeededOnEditMode()
            }
            .onDisappear {
                injected.appState[\.routing.addCollectionItemView.locationSelected] = false
            }
            .navigationBarHidden(true)
    }
}

private extension CollectionFormView {
    @ViewBuilder
    var content: some View {
        VStack(spacing: 0) {
            navigationBar
            VStack(alignment: .leading, spacing: 20) {
                if mode.isAddMode {
                    ImageFormView(selectedImage: $collectionDraft.image)
                }
                BirdNameFormView(draft: collectionDraft, path: $path)
                LocationFormView(selectedCoord: $collectionDraft.coordinate, path: $path, address: collectionDraft.locationAlias)
                DateFormView(title: "발견 일시", date: $collectionDraft.discoveredDate)
                NoteFormView(draft: collectionDraft)
                Spacer()
                visibilityToggleButton
                submitButton
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, SRDesignConstant.defaultPadding)
        }
        .customPopup(
            isPresented: Binding(
                get: { activePopup != .none },
                set: { newValue in
                    if !newValue { activePopup = .none }
                }
            )
        ) {
            switch activePopup {
            case .addModeExitConfirm:
                AnyView(addModeExitConfirmPopup)
            case .editModeSaveConfirm:
                AnyView(editModeSaveConfirmPopup)
            case .editModeDeleteConfirm:
                AnyView(editModeDeleteConfirmPopup)
            case .none:
                fatalError("popupView(for:) called with `.none`, which should never happen because popup is not presented")
            }
        }
    }
    
    var visibilityToggleButton: some View {
        HStack(spacing: 5) {
            Button {
                collectionDraft.isVisible.toggle()
            } label: {
                (collectionDraft.isVisible ? Image.SRIconSet.checkboxDefault : Image.SRIconSet.checkboxChecked)
                    .frame(.defaultIconSizeLarge)
            }
            Text("새록 비공개하기")
                .font(.SRFontSet.body2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    var submitButton: some View {
        Button {
            switch mode {
            case .add:
                submitForm()
            case .edit:
                editCollection()
            }
        } label: {
            Text(mode.submitButtonTitle)
                .font(.SRFontSet.button)
                .frame(maxWidth: .infinity)
                .frame(height: 31)
        }
        .disabled(!collectionDraft.submittable && mode.isAddMode)
        .buttonStyle(.primary)
    }
    
    @ViewBuilder
    var navigationBar: some View {
        switch mode {
        case .add:
            NavigationBar(
                leading: {
                    Text(mode.title)
                        .font(.SRFontSet.headline2)
                },
                trailing: {
                    Button {
                        withAnimation(.bouncy) {
                            activePopup = .addModeExitConfirm
                        }
                    } label: {
                        Image.SRIconSet.delete.frame(.defaultIconSizeLarge)
                    }
                    .buttonStyle(.plain)
                }
            )
        case .edit:
            NavigationBar(
                leading: {
                    Button("취소") {
                        activePopup = .editModeSaveConfirm
                    }
                },
                trailing: {
                    Button("삭제") {
                        activePopup = .editModeDeleteConfirm
                    }
                        .buttonStyle(.plain)
                        .foregroundStyle(.red)
                        .bold()
                }
            )
        }
    }
}

// MARK: - Action Method

extension CollectionFormView {
    func loadBirdIfNeededOnEditMode() {
        if case .edit(let detail) = mode,
           let birdID = detail.birdID,
           collectionDraft.bird == nil {
            Task {
                collectionDraft.bird = try? await injected.interactors.fieldGuide.loadBirdDetails(birdID: birdID)
            }
        }
    }
    
    func submitForm() {
        Task {
            try? await injected.interactors.collection.createCollection(collectionDraft)
            path.removeLast()
        }
    }
    
    func deleteCollection() {
        Task {
            guard let id = collectionDraft.collectionID else { return }
            
            try? await injected.interactors.collection.deleteCollection(id)
            path.removeLast()
            path.removeLast()
        }
    }
    
    func editCollection() {
        Task {
            guard let _ = collectionDraft.collectionID else { return }
            
            do {
                try await injected.interactors.collection.editCollection(collectionDraft)
                path.removeLast()
            } catch {
                print("[EditCollection] ❌ 에러 발생: \(error.localizedDescription)")
                dump(error)
            }
        }
    }
    
    func requestAddress() {
        Task {
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
        }
    }
}

// MARK: - Routable

extension CollectionFormView {
    struct Routing: Equatable {
        var selectedBird: Local.Bird?
        var locationSelected: Bool = false
    }
    
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.addCollectionItemView)
    }
    
    var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.addCollectionItemView)
    }
}

// MARK: - Constants

extension CollectionFormView {
    enum Constants {
        static let imageSize: CGFloat = 100
        static let imageCornerRadius: CGFloat = 10
        static let formHeight: CGFloat = 44
        static let maxNoteLength: Int = 50
        static let deleteButtonOffset: CGFloat = imageSize / 2
    }
}

#Preview {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    appDelegate.rootView
}
