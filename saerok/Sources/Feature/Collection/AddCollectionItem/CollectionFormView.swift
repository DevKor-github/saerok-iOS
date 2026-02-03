//
//  AddCollectionItemView.swift
//  saerok
//
//  Created by HanSeung on 4/24/25.
//


import Combine
import SwiftUI

enum CollectionFormRoute: AppRoute {
    case findBird
    case findLocation
}

struct CollectionFormView: Routable {
    typealias Route = CollectionFormRoute

    let mode: CollectionFormMode
    
    // MARK:  Dependencies
    
    @Environment(\.injected) var injected
    @Environment(\.modelContext) var context
    @EnvironmentObject var coordinator: AppCoordinator
    private var networkService: SRNetworkService { injected.networkService }
    
    // MARK:  Routable
    
    @State var routingState: Routing = .init()
    
    // MARK: View State
    
    private var isBirdChangedToNil: Bool { hadInitialBird && collectionDraft.bird == nil }
    @State private var hadInitialBird: Bool = false
    @State var activePopup: CollectionPopup = .none
    @State private var isPositionInitialized: Bool = false
    @State private var isSubmitting: Bool = false
    @State private var isImageLoading: Bool = false
    @State var collectionDraft: Local.CollectionDraft
    
    @State private var lastPathCount: Int = 0

    private var locationManager: LocationManager { LocationManager.shared }
    
    init(mode: CollectionFormMode) {
        self.mode = mode
        switch mode {
        case .add:
            self.collectionDraft = .init(collectionID: nil)
        case .edit(let detail):
            self.collectionDraft = .fromDetail(detail)
        }
    }
    
    var body: some View {
        content
            .onReceive(routingUpdate) { self.routingState = $0 }
            .navigationDestination(for: Route.self, destination: { route in
                switch route {
                case .findBird:
                    CollectionSearchView(
                        onSelect: { selectedBird in
                            injected.appState[\.routing.addCollectionItemView.selectedBird] = selectedBird
                            coordinator.pop()
                        })
                case .findLocation:
                    FindPlaceView(collectionDraft: $collectionDraft)
                }
            })
            .onChange(of: routingState.selectedBird) { _, selectedBird in
                self.collectionDraft.bird = selectedBird
            }
            .onAppear {
                lastPathCount = coordinator.path.count
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
                if coordinator.path.count < lastPathCount {
                    injected.appState[\.routing.addCollectionItemView] = .init()
                }
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
                BirdNameFormView(draft: $collectionDraft)
                LocationFormView(
                    selectedCoord: $collectionDraft.coordinate,
                    address: collectionDraft.locationAlias
                )
                DateFormView(title: "발견 일시", date: $collectionDraft.discoveredDate)
                NoteFormView(draft: $collectionDraft)
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
        .disabled(isSubmitting)
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
    
    @ViewBuilder
    var submitButton: some View {
        Button {
            submitButtonTapped(self.mode)
        } label: {
            if isSubmitting{
                ProgressView()
            } else {
                Text(mode.submitButtonTitle)
                    .font(.SRFontSet.button)
                    .frame(maxWidth: .infinity)
            }
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
                    Button("취소") { coordinator.pop() }
                },
                trailing: {
                    Button("삭제") { activePopup = .editModeDeleteConfirm }
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
            coordinator.pop()
            injected.appState[\.routing.collectionView.refreshCollections] = UUID()
        }
    }
    
    func deleteCollection() {
        isSubmitting = true
        Task {
            guard let id = collectionDraft.collectionID else { return }

            try? await injected.interactors.collection.deleteCollection(id)
            isSubmitting = false
            coordinator.pop()
            coordinator.pop()
            injected.appState[\.routing.collectionView.refreshCollections] = UUID()
        }
    }
    
    func editCollection() {
        Task {
            guard let _ = collectionDraft.collectionID else { return }
            
            do {
                try await injected.interactors.collection.editCollection(collectionDraft)
                isSubmitting = false
                coordinator.pop()
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
