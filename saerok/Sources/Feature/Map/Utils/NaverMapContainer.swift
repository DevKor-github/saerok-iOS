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
    class Coordinator: NSObject, @preconcurrency NMFMapViewCameraDelegate, NMFMapViewTouchDelegate {
        var parent: NaverMapContainer
        var mapView: NMFMapView?
        let birdClusterMarkerManager = BirdClusterManager()
        
        init(_ parent: NaverMapContainer) {
            self.parent = parent
        }

        func setMapView(_ mapView: NMFMapView) {
            birdClusterMarkerManager.setMapView(mapView)
            self.mapView = mapView
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

        func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
            Task { @MainActor in
                let newCoord = mapView.cameraPosition.target.toDouble
                if parent.coord != newCoord {
                    parent.coord = newCoord
                }
                let newRadius = currentVisibleRadius(latitude: newCoord.0)
                if parent.controller.visibleRadius != newRadius {
                    parent.controller.visibleRadius = newRadius
                }
            }
        }

        func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
            Task { @MainActor in
                let newCoord = latlng.toDouble
                if parent.coord != newCoord {
                    parent.coord = newCoord
                }
            }
        }

        func clearAllMarkers() {
//            birdClusterMarkerManager.refreshBirdMarkers([], touchHandlerGenerator: <#(Local.NearbyCollectionSummary) -> NMFOverlayTouchHandler#>)
        }
        
        func currentVisibleRadius(latitude: Double) -> Double {
            guard let mapView else { return 1000 } 
            let zoomLevel = mapView.zoomLevel
            let screenWidth = UIScreen.main.bounds.width
            let metersPerPt = metersPerPoint(latitude: latitude, zoomLevel: zoomLevel)
            return (metersPerPt * screenWidth) / 2
        }

        private func metersPerPoint(latitude: Double, zoomLevel: Double) -> Double {
            let R = 6378137.0
            let circumference = 2 * Double.pi * R
            let mapWidth = 256 * pow(2.0, zoomLevel)
            return cos(latitude * .pi / 180) * circumference / mapWidth
        }
    }
}

