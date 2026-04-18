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
    enum Action: Equatable {
        case moveCamera(lat: Double, lng: Double, animated: Bool)
        case clearMarkers
        case refreshMarkers
        
        static func == (lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case (.moveCamera(let lat1, let lng1, let animated1), .moveCamera(let lat2, let lng2, let animated2)):
                return lat1 == lat2 && lng1 == lng2 && animated1 == animated2
            case (.clearMarkers, .clearMarkers):
                return true
            case (.refreshMarkers, .refreshMarkers):
                return true
            default:
                return false
            }
        }
    }
    
    let locationManager: LocationManager

    var pendingActions: [Action] = []
    var actionTrigger: UUID = UUID() // Trigger to force updates
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
        actionTrigger = UUID()
    }
    
    func moveToUserLocation() {
        Task { @MainActor in
            if let location = await locationManager.requestAndGetCurrentLocation() {
                pendingActions.append(
                    .moveCamera(
                        lat: location.coordinate.latitude,
                        lng: location.coordinate.longitude,
                        animated: true
                    ))
                actionTrigger = UUID()
            }
        }
    }
    
    func refreshBirdMarkers(_ birds: [Local.NearbyCollectionSummary]) {
        allBirdMarkers = birds
        pendingActions.append(.refreshMarkers)
        actionTrigger = UUID()
    }
    
    func clearMarkers() {
        pendingActions.append(.clearMarkers)
        actionTrigger = UUID()
    }
}
