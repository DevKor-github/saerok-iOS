//
//  NaverMapContainer.swift
//  saerok
//
//  Created by HanSeung on 5/14/25.
//


import NMapsMap
import SwiftUI

struct NaverMapContainer {
    @ObservedObject var controller: MapController
    @Binding var coord: (Double, Double)
}

extension NaverMapContainer: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> NMFNaverMapView {
        let view = NMFNaverMapView()
        view.showZoomControls = false
        view.mapView.positionMode = .normal
        view.mapView.zoomLevel = 15
        
        view.mapView.addCameraDelegate(delegate: context.coordinator)
        view.mapView.touchDelegate = context.coordinator
        
        let coord = NMGLatLng(lat: coord.0, lng: coord.1)
        let cameraUpdate = NMFCameraUpdate(scrollTo: coord)
        view.mapView.moveCamera(cameraUpdate)
        return view
    }
    
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
        let coordinator = context.coordinator
        
        while !controller.pendingActions.isEmpty {
            let action = controller.pendingActions.removeFirst()
            switch action {
            case .moveCamera(let lat, let lng, let animated):
                coordinator.mapView(uiView.mapView, cameraMoveTo: NMGLatLng(lat: lat, lng: lng), animated: animated)
            case .addMarker(let text, let lat, let lng):
                coordinator.marker(text: text, at: NMGLatLng(lat: lat, lng: lng), mapView: uiView.mapView)
            case .clearMarkers:
                coordinator.clearAllMarkers()
            }
        }
    }
}

// MARK: - NMFMapViewCameraDelegate & NMFMapViewTouchDelegate Conformance

extension NaverMapContainer {
    class Coordinator: NSObject, NMFMapViewCameraDelegate, NMFMapViewTouchDelegate {
        var parent: NaverMapContainer
        var markers: [NMFMarker] = []
        
        init(_ parent: NaverMapContainer) {
            self.parent = parent
        }
        
        func mapView(_ mapView: NMFMapView, cameraMoveTo target: NMGLatLng, animated: Bool) {
            let update = NMFCameraUpdate(scrollTo: target)
            if animated {
                update.animation = .fly
                update.animationDuration = 1.5
            }
            mapView.moveCamera(update)
        }
        
        func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
            parent.coord = mapView.cameraPosition.target.toDouble
        }
        
        func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
            parent.coord = latlng.toDouble
        }
    }
}

// MARK: - Coordinator Helper Method

extension NaverMapContainer.Coordinator {
    func marker(text: String, at latlng: NMGLatLng, mapView: NMFMapView) {
        let marker = NMFMarker(position: latlng)
        let image = UIImage(resource: .marker)
        marker.width = 40
        marker.height = 56
        marker.captionText = text
        marker.iconImage = NMFOverlayImage(image: image)
        marker.mapView = mapView
        markers.append(marker)
    }
    
    func clearAllMarkers() {
        for marker in markers {
            marker.mapView = nil
        }
        markers.removeAll()
    }
}

