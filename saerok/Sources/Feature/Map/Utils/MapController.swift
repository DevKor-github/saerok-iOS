//
//  MapController.swift
//  saerok
//
//  Created by HanSeung on 5/14/25.
//


//import CoreLocation
//import Foundation
//
//class MapController: ObservableObject {
//    enum Action {
//        case moveCamera(lat: Double, lng: Double, animated: Bool)
//        case addMarker(text: String, lat: Double, lng: Double)
//        case addBirdMarker(bird: Local.NearbyCollectionSummary)
//        case clearMarkers
//    }
//    
//    let locationManager: LocationManager
//
//    @Published var pendingActions: [Action] = []
//    @Published var selectedBird: Local.NearbyCollectionSummary? = nil
//    @Published var allBirdMarkers: [Local.NearbyCollectionSummary] = []
//
//    init(locationManager: LocationManager) {
//        self.locationManager = locationManager
//    }
//    
//    func select(bird: Local.NearbyCollectionSummary) {
//        selectedBird = bird
//    }
//    
//    func deselect() {
//        selectedBird = nil
//    }
//    
//    func moveCamera(lat: Double, lng: Double, animated: Bool = true) {
//        pendingActions.append(.moveCamera(lat: lat, lng: lng, animated: animated))
//    }
//    
//    @MainActor
//    func moveToUserLocation() {
//        Task {
//            if let location = await locationManager.requestAndGetCurrentLocation() {
//                pendingActions.append(
//                    .moveCamera(
//                        lat: location.coordinate.latitude,
//                        lng: location.coordinate.longitude,
//                        animated: true
//                    ))
//            }
//        }
//    }
//    
//    func addMarker(text: String = "", lat: Double, lng: Double) {
//        pendingActions.append(.addMarker(text: text, lat: lat, lng: lng))
//    }
//    
//    func addBirdMarker(_ bird: Local.NearbyCollectionSummary) {
//        pendingActions.append(.addBirdMarker(bird: bird))
//    }
//    
////    func refreshBirdMarkers(_ birds: [Local.NearbyCollectionSummary]) {
////        birds.forEach { bird in
////            addBirdMarker(bird)
//    //        }
//    //    }
//    
//    func refreshBirdMarkers(_ birds: [Local.NearbyCollectionSummary]) {
//        allBirdMarkers = birds
//    }
//    
//    func clearMarkers() {
//        pendingActions.append(.clearMarkers)
//    }
//}


import CoreLocation
import Foundation

class MapController: ObservableObject {
    enum Action {
        case moveCamera(lat: Double, lng: Double, animated: Bool)
        case clearMarkers
        case refreshMarkers
    }
    
    let locationManager: LocationManager

    @Published var pendingActions: [Action] = []
    @Published var selectedBird: Local.NearbyCollectionSummary? = nil
    @Published var allBirdMarkers: [Local.NearbyCollectionSummary] = []

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
    
//    func refreshBirdMarkers(_ birds: [Local.NearbyCollectionSummary]) {
//        birds.forEach { bird in
//            addBirdMarker(bird)
    //        }
    //    }
    
    func refreshBirdMarkers(_ birds: [Local.NearbyCollectionSummary]) {
        allBirdMarkers = birds
        pendingActions.append(.refreshMarkers)
    }
    
    func clearMarkers() {
        pendingActions.append(.clearMarkers)
    }
}
