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

extension CollectionFormView {
    struct Routing: Equatable {
        var selectedBird: Local.Bird?
        var locationSelected: Bool = false
    }
}

extension CollectionFormView {
    @Observable
    final class ViewModel {
        let mode: CollectionFormMode

        var collectionDraft: Local.CollectionDraft
        private var isBirdChangedToNil: Bool { collectionDraft.bird == nil }
        
        // MARK: Dependencies
        private let appState: Store<AppState>
        private let fieldguideInteractor: FieldGuideInteractor
        private let collectionInteractor: CollectionInteractor

        // MARK: Routing
        private let cancelBag: CancelBag
        
        init(
            appState: Store<AppState>,
            fieldguideInteractor: FieldGuideInteractor,
            collectionInteractor: CollectionInteractor,
            mode: CollectionFormMode,
            bird: Local.Bird?
        ) {
            self.appState = appState
            self.fieldguideInteractor = fieldguideInteractor
            self.collectionInteractor = collectionInteractor
            self.cancelBag = .init()
            self.mode = mode
            
            switch mode {
            case .add:
                collectionDraft = .init(bird: bird, collectionID: nil)
            case .edit(let detail):
                collectionDraft = .fromDetail(detail)
            }
        }
        
        func searchResultSelect(for selectedBird: Local.Bird) {
            collectionDraft.bird = selectedBird
        }
        
        func unselectBird() {
            collectionDraft.bird = nil
        }
        
        func initializeCollecionAdd() {
            appState[\.routing.addCollectionItemView] = .init()
        }
        
        func loadBirdDetail(birdId: Int) async {
            collectionDraft.bird = try? await fieldguideInteractor.loadBirdDetails(birdID: birdId)
        }
        
        func createCollection() async {
            try? await collectionInteractor.createCollection(collectionDraft)
        }
        
        func deleteCollection() async {
            guard let id = collectionDraft.collectionID else { return }

            try? await collectionInteractor.deleteCollection(id)
        }
        
        func editCollection() async throws {
            guard let _ = collectionDraft.collectionID else { return }

            try await collectionInteractor.editCollection(collectionDraft)
        }
        
        func refreshCollectionList() {
            appState[\.routing.collectionView.refreshCollections] = UUID()
        }
        
        func resetSuggestion() async throws {
            try await collectionInteractor.resetSuggestion(collectionDraft.collectionID ?? 0)
        }
    }
}

struct CollectionFormView: View {
    typealias Route = CollectionFormRoute
    
    // MARK:  Dependencies
    @EnvironmentObject var coordinator: AppCoordinator
        
    // MARK: View State
    @State var viewModel: ViewModel
    private var isBirdChangedToNil: Bool { hadInitialBird && viewModel.collectionDraft.bird == nil }
    @State private var hadInitialBird: Bool = false
    @State private var isPositionInitialized: Bool = false
    @State private var isSubmitting: Bool = false
    @State private var isImageLoading: Bool = false
    @State private var lastPathCount: Int = 0
    @State var activePopup: CollectionPopup = .none

    private let locationManager: LocationManager
    
    init(
        viewModel: ViewModel,
        locationManager: LocationManager = .shared
    ) {
        self.viewModel = viewModel
        self.locationManager = locationManager
    }
    
    var body: some View {
        content
            .navigationDestination(for: Route.self, destination: { route in
                switch route {
                case .findBird:
                    CollectionSearchView(
                        onSelect: { selectedBird in
                            viewModel.searchResultSelect(for: selectedBird)
                            coordinator.pop()
                        })
                case .findLocation:
                    FindPlaceView(collectionDraft: viewModel.collectionDraft)
                }
            })
            .onAppear {
                lastPathCount = coordinator.path.count
                loadBirdIfNeededOnEditMode()
            }
            .task {
                if !isPositionInitialized,
                   viewModel.mode.isAddMode,
                   let location = await locationManager.requestAndGetCurrentLocation()?.coordinate {
                    viewModel.collectionDraft.coordinate = (location.latitude, location.longitude)
                    isPositionInitialized = true
                }
            }
            .onDisappear {
                if coordinator.path.count < lastPathCount {
                    viewModel.initializeCollecionAdd()
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
                if viewModel.mode.isAddMode {
                    ImageFormView(selectedImage: $viewModel.collectionDraft.image, isImageLoading: $isImageLoading)
                }
                BirdNameFormView(
                    draft: viewModel.collectionDraft,
                    onTapFindBird: { coordinator.push(CollectionFormView.Route.findBird) },
                    onToggleUnknownBird: { viewModel.unselectBird() }
                )
                LocationFormView(
                    selectedCoord: $viewModel.collectionDraft.coordinate,
                    address: viewModel.collectionDraft.locationAlias
                )
                DateFormView(title: "발견 일시", date: $viewModel.collectionDraft.discoveredDate)
                NoteFormView(draft: $viewModel.collectionDraft)
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
            ),
            config: currentPopupConfig
        )
        .disabled(isSubmitting)
    }
    
    var visibilityToggleButton: some View {
        HStack(spacing: 9) {
            Button {
                viewModel.collectionDraft.isVisible.toggle()
            } label: {
                (
                    viewModel.collectionDraft.isVisible
                    ? Image.SRIconSet.checkboxDefault
                    : Image.SRIconSet.checkboxChecked
                )
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
            submitButtonTapped(viewModel.mode)
        } label: {
            if isSubmitting{
                ProgressView()
            } else {
                Text(viewModel.mode.submitButtonTitle)
                    .font(.SRFontSet.button)
                    .frame(maxWidth: .infinity)
            }
        }
        .disabled(!viewModel.collectionDraft.submittable && viewModel.mode.isAddMode)
        .disabled(isSubmitting)
        .srStyled(.primaryButton)
    }
    
    @ViewBuilder
    var navigationBar: some View {
        switch viewModel.mode {
        case .add:
            NavigationBar(
                leading: {
                    Text(viewModel.mode.title)
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
        if case .edit(let detail) = viewModel.mode,
           let birdId = detail.birdID,
           viewModel.collectionDraft.bird == nil
        {
            Task {
                await viewModel.loadBirdDetail(birdId: birdId)
                hadInitialBird = true
            }
        }
    }
    
    func submitForm() {
        Task {
            await viewModel.createCollection()
            isSubmitting = false
            coordinator.pop()
            viewModel.refreshCollectionList()
        }
    }
    
    func deleteCollection() {
        isSubmitting = true
        Task {
            await viewModel.deleteCollection()
            isSubmitting = false
            coordinator.pop()
            coordinator.pop()
            viewModel.refreshCollectionList()
        }
    }
    
    func editCollection() {
        Task {
            do {
                try await viewModel.editCollection()
                isSubmitting = false
                coordinator.pop()
            } catch { }
        }
    }
    
    func resetSuggestion() {
        Task {
            try? await viewModel.resetSuggestion()
        }
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
