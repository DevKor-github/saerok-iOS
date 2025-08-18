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

