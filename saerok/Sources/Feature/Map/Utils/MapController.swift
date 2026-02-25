//
//  MapController.swift
//  saerok
//
//  Created by HanSeung on 5/14/25.
//

import CoreLocation
import Foundation

@Observable
final class MapController {
    enum Action {
        case moveCamera(lat: Double, lng: Double, animated: Bool)
        case clearMarkers
        case refreshMarkers
    }
    
    let locationManager: LocationManager

    var pendingActions: [Action] = []
    var selectedBird: Local.NearbyCollectionSummary? = nil
    var allBirdMarkers: [Local.NearbyCollectionSummary] = []
    var visibleRadius: Double = 1000

    init(locationManager: LocationManager) {
        self.locationManager = locationManager
    }
    
    func select(bird: Local.NearbyCollectionSummary) {
        selectedBird = bird
    }
    
    func deselect() {
        selectedBird = nil
    }
    
    func moveCamera(lat: Double, lng: Double, animated: Bool = true) {
        pendingActions.append(.moveCamera(lat: lat, lng: lng, animated: animated))
    }
    
    @MainActor
    func moveToUserLocation() {
        Task {
            if let location = await locationManager.requestAndGetCurrentLocation() {
                pendingActions.append(
                    .moveCamera(
                        lat: location.coordinate.latitude,
                        lng: location.coordinate.longitude,
                        animated: true
                    ))
            }
        }
    }
    
    func refreshBirdMarkers(_ birds: [Local.NearbyCollectionSummary]) {
        allBirdMarkers = birds
        pendingActions.append(.refreshMarkers)
    }
    
    func clearMarkers() {
        pendingActions.append(.clearMarkers)
    }
}
