//
//  LocationManager.swift
//  saerok
//
//  Created by HanSeung on 6/15/25.
//


import CoreLocation
import Combine


final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @MainActor static let shared = LocationManager()
    private let manager = CLLocationManager()

    @Published var currentLocation: CLLocation?
    private var locationContinuation: CheckedContinuation<CLLocation?, Never>?

    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.requestWhenInUseAuthorization()
    }

    func requestAndGetCurrentLocation() async -> CLLocation? {
        if let last = manager.location {
            return last
        }
        return await withCheckedContinuation { continuation in
            self.locationContinuation = continuation
            self.manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationContinuation?.resume(returning: locations.first)
        locationContinuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(returning: nil)
        locationContinuation = nil
    }
}

