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
    @Observable
    final class ViewModel {
        let mode: CollectionFormMode

        var collectionDraft: Local.CollectionDraft
        private(set) var isSubmitting: Bool = false
        var isImageLoading: Bool = false
        private(set) var hadInitialBird: Bool = false
        private(set) var isPositionInitialized: Bool = false
        private(set) var activePopup: CollectionPopup = .none
        private(set) var output: Output?

        var isBirdChangedToNil: Bool { hadInitialBird && collectionDraft.bird == nil }

        // MARK: Dependencies
        private let appStore: AppStore
        private let fieldguideInteractor: FieldGuideInteractor
        private let collectionInteractor: CollectionInteractor

        // MARK: Routing
        private let cancelBag: CancelBag

        enum Output: Equatable {
            case submitCompleted
            case deleteCompleted
        }

        init(
            appStore: AppStore,
            fieldguideInteractor: FieldGuideInteractor,
            collectionInteractor: CollectionInteractor,
            mode: CollectionFormMode,
            bird: Local.Bird?
        ) {
            self.appStore = appStore
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

        func markPositionInitialized() { isPositionInitialized = true }
        func markHadInitialBird() { hadInitialBird = true }
        func showPopup(_ popup: CollectionPopup) { activePopup = popup }
        func dismissPopup() { activePopup = .none }
        func resetOutput() { output = nil }

        func searchResultSelect(for selectedBird: Local.Bird) {
            collectionDraft.bird = selectedBird
        }

        func unselectBird() {
            collectionDraft.bird = nil
        }

        func initializeCollecionAdd() { }

        func loadBirdDetail(birdId: Int) async {
            collectionDraft.bird = try? await fieldguideInteractor.loadBirdDetails(birdID: birdId)
        }

        func refreshCollectionList() {
            appStore.send(.refreshCollections)
        }

        func performSubmit() async {
            isSubmitting = true
            do {
                try await collectionInteractor.createCollection(collectionDraft)
            } catch {
                try? await collectionInteractor.createCollection(collectionDraft)
            }
            isSubmitting = false
            output = .submitCompleted
        }

        func performDelete() async {
            guard let id = collectionDraft.collectionID else { return }
            isSubmitting = true
            try? await collectionInteractor.deleteCollection(id)
            isSubmitting = false
            output = .deleteCompleted
        }

        func performEdit(resetSuggestion shouldReset: Bool = false) async {
            guard collectionDraft.collectionID != nil else { return }
            isSubmitting = true
            do {
                if shouldReset {
                    try await collectionInteractor.resetSuggestion(collectionDraft.collectionID ?? 0)
                }
                try await collectionInteractor.editCollection(collectionDraft)
                output = .submitCompleted
            } catch { }
            isSubmitting = false
        }
    }
}

struct CollectionFormView: View {
    typealias Route = CollectionFormRoute
    
    // MARK:  Dependencies
    @EnvironmentObject var coordinator: AppCoordinator

    // MARK: View State
    @Bindable var viewModel: ViewModel
    @State private var lastPathCount: Int = 0

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
                if !viewModel.isPositionInitialized,
                   viewModel.mode.isAddMode,
                   let location = await locationManager.requestAndGetCurrentLocation()?.coordinate {
                    viewModel.collectionDraft.coordinate = (location.latitude, location.longitude)
                    viewModel.markPositionInitialized()
                }
            }
            .onDisappear {
                if coordinator.path.count < lastPathCount {
                    viewModel.initializeCollecionAdd()
                }
            }
            .onChange(of: viewModel.output, initial: true) { _, output in
                handleOutput(output)
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
                    ImageFormView(selectedImage: $viewModel.collectionDraft.image, isImageLoading: $viewModel.isImageLoading)
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
        .srPopup(
            isPresented: Binding(
                get: { viewModel.activePopup != .none },
                set: { newValue in
                    if !newValue { viewModel.dismissPopup() }
                }
            ),
            config: currentPopupConfig
        )
        .disabled(viewModel.isSubmitting)
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
                .frame(.large)
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
            if viewModel.isSubmitting {
                ProgressView()
            } else {
                Text(viewModel.mode.submitButtonTitle)
                    .font(.SRFontSet.button)
                    .frame(maxWidth: .infinity)
            }
        }
        .disabled(!viewModel.collectionDraft.submittable && viewModel.mode.isAddMode)
        .disabled(viewModel.isSubmitting)
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
                            viewModel.showPopup(.addModeExitConfirm)
                        }
                    } label: {
                        Image.SRIconSet.delete.frame(.large)
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
                    Button("삭제") { viewModel.showPopup(.editModeDeleteConfirm) }
                        .buttonStyle(.plain)
                        .foregroundStyle(.red)
                        .bold()
                }
            )
        }
    }
}

// MARK: - Button Actions
extension CollectionFormView {
    func submitButtonTapped(_ mode: CollectionFormMode) {
        switch mode {
        case .add:
            Task { await viewModel.performSubmit() }
        case .edit:
            if viewModel.isBirdChangedToNil {
                viewModel.showPopup(.editModeSaveConfirm)
            } else {
                Task { await viewModel.performEdit() }
            }
        }
    }

    func deleteCollection() {
        Task { await viewModel.performDelete() }
    }

    func loadBirdIfNeededOnEditMode() {
        if case .edit(let detail) = viewModel.mode,
           let birdId = detail.birdID,
           viewModel.collectionDraft.bird == nil
        {
            Task {
                await viewModel.loadBirdDetail(birdId: birdId)
                viewModel.markHadInitialBird()
            }
        }
    }

    private func handleOutput(_ output: ViewModel.Output?) {
        guard let output else { return }
        switch output {
        case .submitCompleted:
            coordinator.pop()
            viewModel.refreshCollectionList()
        case .deleteCompleted:
            coordinator.pop()
            coordinator.pop()
            viewModel.refreshCollectionList()
        }
        viewModel.resetOutput()
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

// MARK: - Wrapper

/// navigationDestination 클로저가 재평가될 때마다 ViewModel이 새로 생성되는 문제를 막기 위한 래퍼.
/// @State가 SwiftUI 뷰 정체성(identity)을 통해 ViewModel을 보존한다.
struct CollectionFormViewWrapper: View {
    @State private var viewModel: CollectionFormView.ViewModel

    init(factory: ViewModelFactory, mode: CollectionFormMode, bird: Local.Bird? = nil) {
        _viewModel = State(wrappedValue: factory.makeCollectionFormViewModel(mode: mode, bird: bird))
    }

    var body: some View {
        CollectionFormView(viewModel: viewModel)
    }
}
