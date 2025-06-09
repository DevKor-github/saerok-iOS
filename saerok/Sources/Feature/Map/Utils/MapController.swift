//
//  MapController.swift
//  saerok
//
//  Created by HanSeung on 5/14/25.
//


import CoreLocation
import Foundation

class MapController: ObservableObject {
    enum Action {
        case moveCamera(lat: Double, lng: Double, animated: Bool)
        case addMarker(text: String, lat: Double, lng: Double)
        case addBirdMarker(bird: Local.CollectionDetail)
        case clearMarkers
    }
    
    @Published var pendingActions: [Action] = []
    @Published var selectedBird: Local.CollectionDetail? = nil
    
    func select(bird: Local.CollectionDetail) {
        selectedBird = bird
    }
    
    func deselect() {
        selectedBird = nil
    }
    
    func moveCamera(lat: Double, lng: Double, animated: Bool = true) {
        pendingActions.append(.moveCamera(lat: lat, lng: lng, animated: animated))
    }
    
    func moveToUserLocation() {
        if let location = CLLocationManager().location {
            pendingActions.append(
                .moveCamera(
                    lat: location.coordinate.latitude,
                    lng: location.coordinate.longitude,
                    animated: true
                ))
        }
    }
    
    func addMarker(text: String = "", lat: Double, lng: Double) {
        pendingActions.append(.addMarker(text: text, lat: lat, lng: lng))
    }
    
    func addBirdMarker(_ bird: Local.CollectionDetail) {
        pendingActions.append(.addBirdMarker(bird: bird))
    }
    
    func refreshBirdMarkers(_ birds: [Local.CollectionDetail]) {
        birds.forEach { bird in
            addBirdMarker(bird)
        }
    }
    
    func clearMarkers() {
        pendingActions.append(.clearMarkers)
    }
}
