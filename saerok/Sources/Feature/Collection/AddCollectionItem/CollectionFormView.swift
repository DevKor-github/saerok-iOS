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
    
    private var isBirdChangedToNil: Bool { hadInitialBird && collectionDraft.bird == nil }
    @State private var hadInitialBird: Bool = false
    @State var activePopup: CollectionPopup = .none
    @State private var isPositionInitialized: Bool = false
    @State private var isSubmitting: Bool = false
    @State private var isImageLoading: Bool = false
    @StateObject var collectionDraft: Local.CollectionDraft
    
    private var locationManager: LocationManager { LocationManager.shared }
    
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
                    CollectionSearchView(
                        path: $path,
                        onSelect: { selectedBird in
                            injected.appState[\.routing.addCollectionItemView.selectedBird] = selectedBird
                            path.removeLast()
                        })
                case .findLocation:
                    FindPlaceView(collectionDraft: collectionDraft, path: $path)
                }
            })
            .onChange(of: routingState.selectedBird) { _, selectedBird in
                self.collectionDraft.bird = selectedBird
            }
            .onAppear {
                injected.appState[\.routing.collectionView.addCollection] = false
                loadBirdIfNeededOnEditMode()
            }
            .task {
                if !isPositionInitialized,
                   mode.isAddMode,
                   let location = await locationManager.requestAndGetCurrentLocation()?.coordinate {
                    collectionDraft.coordinate = (location.latitude, location.longitude)
                    isPositionInitialized = true
                }
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
                    ImageFormView(selectedImage: $collectionDraft.image, isImageLoading: $isImageLoading)
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
                AnyView(EmptyView())
            }
        }
    }
    
    var visibilityToggleButton: some View {
        HStack(spacing: 9) {
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
            submitButtonTapped(self.mode)
        } label: {
            Text(mode.submitButtonTitle)
                .font(.SRFontSet.button)
                .frame(maxWidth: .infinity)
        }
        .disabled(!collectionDraft.submittable && mode.isAddMode)
        .disabled(isSubmitting)
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
                        path.removeLast()
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

// MARK: - Networking & Button Action

extension CollectionFormView {
    func submitButtonTapped(_ mode: CollectionFormMode) {
        isSubmitting = true
        
        switch mode {
        case .add:
            submitForm()
        case .edit:
            if isBirdChangedToNil {
                activePopup = .editModeSaveConfirm
            } else {
                editCollection()
            }
        }
    }
    
    func loadBirdIfNeededOnEditMode() {
        if case .edit(let detail) = mode,
           let birdID = detail.birdID,
           collectionDraft.bird == nil
        {
            Task {
                collectionDraft.bird = try? await injected.interactors.fieldGuide.loadBirdDetails(
                    birdID: birdID
                )
                hadInitialBird = true
            }
        }
    }
    
    func submitForm() {
        Task {
            try? await injected.interactors.collection.createCollection(collectionDraft)
            isSubmitting = false
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
                isSubmitting = false
                path.removeLast()
            } catch {
                print("[EditCollection] ❌ 에러 발생: \(error.localizedDescription)")
                dump(error)
            }
        }
    }
    
    func resetSuggestion() {
        Task {
            try await injected.interactors.collection.resetSuggestion(collectionDraft.collectionID ?? 0)
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
