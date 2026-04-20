import Foundation
import SwiftUI

extension MapView {
    struct Routing: Equatable {
        var navigation: Coordinate?
    }
}

extension MapView.Routing {
    struct Coordinate: Equatable {
        let latitude: Double
        let longitude: Double
    }
}

extension MapView {
    @Observable
    final class ViewModel {
        enum Output: Equatable {
            case navigateTo(coord: Routing.Coordinate)
        }
        
        private let locationManager: LocationManager
        private let mapInteractor: MapInteractor
        private let appState: Store<AppState>
        var isGuest: Bool { appState[\.authStatus] == .guest }

        let mapController: MapController

        // MARK: View State
        private(set) var output: Output?
        private(set) var mapViewState: LoadState<Void> = .notRequested
        var position: (Double, Double) = (37.59080, 127.0278)
        var address: String = ""
        var text: String = ""
        var response: [Local.KakaoPlace] = []
        var mode: SearchInputBar.Mode = .idle
        var isMineOnly: Bool = false
        var item: [Local.NearbyCollectionSummary] = []
        var isNavigating: Bool = false

        private var searchDebounceTask: Task<Void, Never>? = nil
        private let cancelBag = CancelBag()

        var isModeIdle: Bool { mode == .idle }
        
        init(
            locationManager: LocationManager = .shared,
            mapInteractor: MapInteractor,
            appState: Store<AppState>
        ) {
            self.locationManager = locationManager
            self.mapInteractor = mapInteractor
            self.appState = appState
            self.mapController = .init(locationManager: locationManager)
            
            appState
                .updates(for: \.routing.mapView.navigation)
                .compactMap { $0 }
                .weakSink(on: self) { viewModel, coord in
                    viewModel.output = .navigateTo(coord: coord)
                }
                .store(in: cancelBag)
        }
        
        @MainActor
        func onAppear() {
            reloadAddress()
        }
        
        func handleRoutingNavigationUpdate(_ update: MapView.Routing.Coordinate?) {
            guard let update = update, !isNavigating else { return }
            isNavigating = true
            Task { @MainActor in
                position = (update.latitude, update.longitude)
                mapController.moveCamera(lat: update.latitude, lng: update.longitude, animated: true)
                try? await Task.sleep(for: .seconds(0.3))
                try? await fetchPosition(update.latitude, update.longitude)
                isNavigating = false
                appState[\.routing.mapView.navigation] = nil
            }
        }

        func initialLoad() async {
            guard case .notRequested = mapViewState else { return }

            mapViewState = .loading
            if let location = await locationManager.requestAndGetCurrentLocation()?.coordinate {
                if !isNavigating {
                    position = (location.latitude, location.longitude)
                }
                mapViewState = .success(())
                try? await fetchNearby(mineOnly: isMineOnly)
            } else {
                mapViewState = .notRequested
            }
        }

        @MainActor
        func searchCellTapped(_ item: Local.KakaoPlace) {
            position = (item.latitude, item.longitude)
            mapController.moveCamera(lat: item.latitude, lng: item.longitude, animated: true)
            mode = .idle
        }

        func globalToggleButtonTapped() {
            Task {
                do {
                    HapticManager.shared.trigger(.light)
                    try await fetchNearby(mineOnly: !isMineOnly)
                    withAnimation(.bouncy(duration: 0.4)) {
                        isMineOnly.toggle()
                    }
                    HapticManager.shared.trigger(.success)
                } catch {
                    HapticManager.shared.trigger(.error)
                }
            }
        }

        func refreshButtonTapped() {
            Task {
                HapticManager.shared.trigger(.light)
                try? await fetchNearby(mineOnly: self.isMineOnly)
                HapticManager.shared.trigger(.success)
            }
        }

        @MainActor
        func fetchNearby(mineOnly: Bool) async throws {
            let radius = mapController.visibleRadius
            item = try await mapInteractor.fetchNearbyCollections(
                lat: position.0,
                lng: position.1,
                rad: radius,
                isMineOnly: mineOnly,
                isGuest: isGuest
            )
            clearMarkers()
            loadMarkers(item)
        }

        @MainActor
        func fetchPosition(_ lat: Double, _ lng: Double) async throws {
            item = try await mapInteractor.fetchNearbyCollections(
                lat: lat,
                lng: lng,
                rad: 500,
                isMineOnly: isMineOnly,
                isGuest: isGuest
            )
            loadMarkers(item)
        }

        @MainActor
        func clearMarkers() {
            mapController.clearMarkers()
        }

        @MainActor
        func loadMarkers(_ items: [Local.NearbyCollectionSummary]) {
            mapController.refreshBirdMarkers(items)
        }

        func performSearch() async {
            do {
                let places = try await mapInteractor.search(keyword: text)
                response = places
                mode = .resultShown
            } catch { }
        }

        func performSearchDebounced() {
            searchDebounceTask = Task.debounce(task: searchDebounceTask) {
                await self.performSearch()
            }
        }

        func reloadAddress() {
            searchDebounceTask = Task.debounce(task: searchDebounceTask) {
                let addr = try await self.mapInteractor.address(for: self.position.0, latitude: self.position.1)
                await MainActor.run {
                    self.address = addr
                }
            }
        }
        
        func resetOutput() {
            self.output = nil
        }
    }
}
