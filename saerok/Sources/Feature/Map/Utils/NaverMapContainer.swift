//
//  NaverMapContainer.swift
//  saerok
//
//  Created by HanSeung on 5/14/25.
//

//import NMapsMap
//import SwiftUI
//
//// MARK: - NaverMapContainer
//
//struct NaverMapContainer {
//    @ObservedObject var controller: MapController
//    @Binding var coord: (Double, Double)
//}
//
//extension NaverMapContainer: UIViewRepresentable {
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    func makeUIView(context: Context) -> NMFNaverMapView {
//        let view = NMFNaverMapView()
//        view.showZoomControls = false
//        view.mapView.positionMode = .normal
//        view.mapView.zoomLevel = 15
//        
//        view.mapView.addCameraDelegate(delegate: context.coordinator)
//        view.mapView.touchDelegate = context.coordinator
//        
//        let coord = NMGLatLng(lat: coord.0, lng: coord.1)
//        let cameraUpdate = NMFCameraUpdate(scrollTo: coord)
//        view.mapView.moveCamera(cameraUpdate)
//        
//        return view
//    }
//    
//    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
//        let coordinator = context.coordinator
//
//        DispatchQueue.main.async {
//            while !controller.pendingActions.isEmpty {
//                let action = controller.pendingActions.removeFirst()
//                switch action {
//                case .moveCamera(let lat, let lng, let animated):
//                    coordinator.mapView(
//                        uiView.mapView,
//                        cameraMoveTo: NMGLatLng(lat: lat, lng: lng),
//                        animated: animated
//                    )
//                    
//                case .addMarker(let text, let lat, let lng):
//                    coordinator.marker(
//                        text: text,
//                        at: NMGLatLng(lat: lat, lng: lng),
//                        mapView: uiView.mapView
//                    )
//                    
//                case .addBirdMarker(let bird):
//                    coordinator.addBirdImageMarker(bird, mapView: uiView.mapView)
//                    
//                case .clearMarkers:
//                    coordinator.clearAllMarkers()
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Coordinator Class
//
//extension NaverMapContainer {
//    class Coordinator: NSObject, NMFMapViewCameraDelegate, NMFMapViewTouchDelegate {
//        var parent: NaverMapContainer
//        let birdMarkerManager = BirdMarkerManager()
//        
//        var markers: [NMFMarker] {
//            birdMarkerManager.markers
//        }
//        
//        init(_ parent: NaverMapContainer) {
//            self.parent = parent
//        }
//        
//        func mapView(_ mapView: NMFMapView, cameraMoveTo target: NMGLatLng, animated: Bool) {
//            let update = NMFCameraUpdate(scrollTo: target)
//            if animated {
//                update.animation = .fly
//                update.animationDuration = 1.5
//            }
//            mapView.moveCamera(update)
//        }
//        
//        @MainActor
//        func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
//            parent.coord = mapView.cameraPosition.target.toDouble
//            updateMarkersVisibility(mapView: mapView, zoom: mapView.cameraPosition.zoom)
//        }
//        
//        func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
//            parent.coord = latlng.toDouble
//        }
//    }
//}
//
//// MARK: - Coordinator Helpers
//
//private extension NaverMapContainer.Coordinator {
//    func updateMarkersVisibility(mapView: NMFMapView, zoom: Double) {
//        for marker in markers {
//            let name = marker.userInfo["name"] as? String ?? ""
//            if zoom >= 14.0 {
//                marker.captionText = name
//                (marker.userInfo["noteMarker"] as? NMFMarker)?.mapView = mapView
//            } else {
//                marker.captionText = ""
//                (marker.userInfo["noteMarker"] as? NMFMarker)?.mapView = nil
//            }
//        }
//    }
//    
//    func marker(text: String, at latlng: NMGLatLng, mapView: NMFMapView) {
//        birdMarkerManager.addBasicMarker(text: text, at: latlng, to: mapView)
//    }
//    
//    func addBirdImageMarker(_ collection: Local.NearbyCollectionSummary, mapView: NMFMapView) {
//        birdMarkerManager.addMarker(for: collection, on: mapView) { [weak self] _ in
//            self?.parent.controller.select(bird: collection)
//            return true
//        }
//    }
//    
//    func clearAllMarkers() {
//        birdMarkerManager.clearAllMarkers()
//    }
//}



// ---
//
//  NaverMapContainer.swift
//  saerok
//
//  Created by HanSeung on 5/14/25.
//

import NMapsMap
import SwiftUI

// MARK: - NaverMapContainer

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

        context.coordinator.setMapView(view.mapView)
        context.coordinator.refreshClusterMarkers()

        return view
    }

    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
        let coordinator = context.coordinator

        DispatchQueue.main.async {
            while !controller.pendingActions.isEmpty {
                let action = controller.pendingActions.removeFirst()
                switch action {
                case .moveCamera(let lat, let lng, let animated):
                    coordinator.mapView(
                        uiView.mapView,
                        cameraMoveTo: NMGLatLng(lat: lat, lng: lng),
                        animated: animated
                    )
                case .clearMarkers:
                    coordinator.clearAllMarkers()
                case .refreshMarkers:
                    coordinator.refreshClusterMarkers()
                }
            }
        }
    }
}

// MARK: - Coordinator Class

extension NaverMapContainer {
    class Coordinator: NSObject, NMFMapViewCameraDelegate, NMFMapViewTouchDelegate {
        var parent: NaverMapContainer
        let birdClusterMarkerManager = BirdClusterManager()

        init(_ parent: NaverMapContainer) {
            self.parent = parent
        }

        func setMapView(_ mapView: NMFMapView) {
            birdClusterMarkerManager.setMapView(mapView)
        }

        func refreshClusterMarkers() {
            birdClusterMarkerManager.refreshBirdMarkers(parent.controller.allBirdMarkers) { [weak self] bird in
                return { _ in
                    self?.parent.controller.select(bird: bird)
                    return true
                }
            }
        }
        
        func mapView(_ mapView: NMFMapView, cameraMoveTo target: NMGLatLng, animated: Bool) {
            let update = NMFCameraUpdate(scrollTo: target)
            if animated {
                update.animation = .fly
                update.animationDuration = 1.5
            }
            mapView.moveCamera(update)
        }

        @MainActor
        func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
            parent.coord = mapView.cameraPosition.target.toDouble
        }

        func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
            parent.coord = latlng.toDouble
        }

        func clearAllMarkers() {
//            birdClusterMarkerManager.refreshBirdMarkers([], touchHandlerGenerator: <#(Local.NearbyCollectionSummary) -> NMFOverlayTouchHandler#>)
        }
    }
}

