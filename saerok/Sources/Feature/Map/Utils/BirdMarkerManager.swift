//
//  BirdMarkerManager.swift
//  saerok
//
//  Created by HanSeung on 5/22/25.
//


import NMapsMap

final class BirdMarkerManager {
    private(set) var markers: [NMFMarker] = []

    func addBasicMarker(text: String, at latlng: NMGLatLng, to mapView: NMFMapView) {
        let marker = NMFMarker(position: latlng)
        marker.width = 40
        marker.height = 56
        marker.captionText = text
        marker.iconImage = NMFOverlayImage(image: UIImage(resource: .marker))
        marker.mapView = mapView
        markers.append(marker)
    }
    
    func addMarker(
        for collection: Local.CollectionDetail,
        on mapView: NMFMapView,
        _ touchHandler: NMFOverlayTouchHandler? = nil
    ) {
        let marker = createMarker(for: collection, touchHandler)
        marker.mapView = mapView
        markers.append(marker)

        attachNote(to: marker, note: collection.note)

        if let url = URL(string: collection.imageURL) {
            loadAndApplyImage(for: marker, from: url, collection: collection, mapView: mapView)
        }
    }
    
    func clearAllMarkers() {
        for marker in markers {
            marker.mapView = nil
        }
        markers.removeAll()
    }

    private func createMarker(
        for collection: Local.CollectionDetail,
        _ touchHandler: NMFOverlayTouchHandler? = nil
    ) -> NMFMarker {
        let marker = NMFMarker(position: NMGLatLng(lat: collection.coordinate.latitude, lng: collection.coordinate.longitude))
        marker.width = 60
        marker.height = 60
        marker.captionText = ""
        marker.iconImage = NMFOverlayImage(image: UIImage(resource: .circle))
        marker.userInfo = [
            "name": collection.birdName ?? "어디선가 본 새",
            "note": collection.note,
            "infoWindow": NMFInfoWindow(),
            "touchHandler": touchHandler ?? {}
         ]
        if let handler = touchHandler {
            marker.touchHandler = handler
        }
        
        return marker
    }

    private func attachNote(to marker: NMFMarker, note: String) {
        let infoWindow = NMFInfoWindow()
        let dataSource = NMFInfoWindowDefaultTextSource.data()
        dataSource.title = note
        infoWindow.dataSource = dataSource
        marker.userInfo["infoWindow"] = infoWindow
    }

    private func loadAndApplyImage(for marker: NMFMarker, from url: URL, collection: Local.CollectionDetail, mapView: NMFMapView) {
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard let image = UIImage(data: data) else { return }

                let finalImage = await MainActor.run {
                    BirdMarkerImageRenderer.make(from: image)
                }

                await MainActor.run {
                    updateMarkerImage(marker, with: finalImage)
                    addBirdNoteMarker(collection, anchorMarker: marker, mapView: mapView)
                }
            } catch {
                print("❌ Failed to load bird image:", error)
            }
        }
    }
    
    private func applyImage(_ image: UIImage, to marker: NMFMarker, bird: Local.CollectionDetail, mapView: NMFMapView) {
        Task {
            let finalImage = await MainActor.run {
                BirdMarkerImageRenderer.make(from: image)
            }

            await MainActor.run {
                marker.iconImage = NMFOverlayImage(image: finalImage)
                addBirdNoteMarker(bird, anchorMarker: marker, mapView: mapView)
            }
        }
    }
    
    private func addBirdNoteMarker(_ collection: Local.CollectionDetail, anchorMarker: NMFMarker, mapView: NMFMapView) {
        let noteImage = NoteBalloonRenderer.make(note: collection.note)
        let noteMarker = NMFMarker(position: anchorMarker.position)
        noteMarker.iconImage = NMFOverlayImage(image: noteImage)
        noteMarker.width = CGFloat(noteImage.size.width)
        noteMarker.height = CGFloat(noteImage.size.height)
        noteMarker.mapView = nil
        noteMarker.touchHandler = anchorMarker.userInfo["touchHandler"] as? NMFOverlayTouchHandler

        anchorMarker.userInfo["noteMarker"] = noteMarker
    }

    private func updateMarkerImage(_ marker: NMFMarker, with image: UIImage) {
        marker.iconImage = NMFOverlayImage(image: image)
    }
}
