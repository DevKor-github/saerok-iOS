//
//  Location+Extension.swift
//  saerok
//
//  Created by HanSeung on 5/14/25.
//


import CoreLocation
import NMapsGeometry

extension CLLocationCoordinate2D {
    func toNMGLatLng() -> NMGLatLng {
        return NMGLatLng(from: self)
    }
    
    func toDouble() -> (Double, Double) {
        return (self.toNMGLatLng().lat, self.toNMGLatLng().lng)
    }
}

extension NMGLatLng {
    var toDouble: (Double, Double) {
        return (self.lat, self.lng)
    }
}
