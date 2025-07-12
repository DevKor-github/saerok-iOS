//
//  MarkerManager.swift
//  saerok
//
//  Created by HanSeung on 7/9/25.
//

import NMapsMap

// MARK: - Marker Updater

final class MarkerUpdater: NMCDefaultClusterMarkerUpdater, NMCLeafMarkerUpdater {
    var clusterer: NMCClusterer<ItemKey>?

    func updateLeafMarker(_ info: NMCLeafMarkerInfo, _ marker: NMFMarker) {
        guard let tag = info.tag as? ItemData,
              let testMarker = marker as? SRMarker,
              let mapView = clusterer?.mapView else { return }

        tag.marker = testMarker
        testMarker.touchHandler = tag.touchHandler
        testMarker.userInfo = ["tag": tag]

        if let image = tag.image {
            testMarker.iconImage = NMFOverlayImage(image: image)
        }

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 50_000_000)
            if testMarker.mapView === mapView {
                testMarker.showInfoWindow(on: mapView)
            }
        }
    }
}

// MARK: - Marker Data

final class ItemData: NSObject {
    let birdData: Local.NearbyCollectionSummary
    var image: UIImage?
    var touchHandler: NMFOverlayTouchHandler?
    weak var marker: NMFMarker?

    init(birdData: Local.NearbyCollectionSummary, touchHandler: NMFOverlayTouchHandler? = nil) {
        self.birdData = birdData
        self.touchHandler = touchHandler
    }

    func loadImage() {
        guard image == nil,
              let urlString = birdData.imageUrl,
              let url = URL(string: urlString) else { return }

        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let rawImage = UIImage(data: data) {
                    let rendered = BirdMarkerImageRenderer.make(from: rawImage)
                    await MainActor.run {
                        self.image = rendered
                        self.marker?.iconImage = NMFOverlayImage(image: rendered)
                    }
                }
            } catch {
                print("❌ Failed to load image: \(error)")
            }
        }
    }
}

// MARK: - Marker Key

final class ItemKey: NSObject, NMCClusteringKey {
    let identifier: Int
    let position: NMGLatLng

    init(identifier: Int, position: NMGLatLng) {
        self.identifier = identifier
        self.position = position
        super.init()
    }

    static func markerKey(identifier: Int, position: NMGLatLng) -> ItemKey {
        return ItemKey(identifier: identifier, position: position)
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? ItemKey else { return false }
        return self.identifier == object.identifier
    }

    override var hash: Int {
        return identifier.hashValue
    }

    func copy(with zone: NSZone? = nil) -> Any {
        return ItemKey(identifier: identifier, position: position)
    }
}

// MARK: - Cluster Manager

final class BirdClusterManager {
    private let clusterer: NMCClusterer<ItemKey>
    private let markerUpdater = MarkerUpdater()
    private weak var mapView: NMFMapView?

    init() {
        let builder = NMCComplexBuilder<ItemKey>()
        builder.maxScreenDistance = 10
        builder.minClusteringZoom = 4
        builder.maxClusteringZoom = 15
        builder.animationDuration = 0

        builder.clusterMarkerUpdater = markerUpdater
        builder.leafMarkerUpdater = markerUpdater
        builder.markerManager = MarkerManager()

        self.clusterer = builder.build()
        self.markerUpdater.clusterer = clusterer
        (builder.markerManager as? MarkerManager)?.mapView = mapView
    }

    func setMapView(_ mapView: NMFMapView) {
        self.mapView = mapView
        self.clusterer.mapView = mapView
    }

    func refreshBirdMarkers(
        _ birds: [Local.NearbyCollectionSummary],
        touchHandlerGenerator: @escaping (Local.NearbyCollectionSummary) -> NMFOverlayTouchHandler
    ) {
        clusterer.clear()

        var keyTagMap: [ItemKey: ItemData] = [:]

        for bird in birds {
            let handler = touchHandlerGenerator(bird)
            let key = ItemKey(identifier: bird.collectionId, position: NMGLatLng(lat: bird.latitude, lng: bird.longitude))
            let data = ItemData(birdData: bird, touchHandler: handler)
            data.loadImage()
            keyTagMap[key] = data
        }

        clusterer.addAll(keyTagMap)
    }
}

// MARK: - Marker Manager

final class MarkerManager: NMCMarkerManager {
    weak var mapView: NMFMapView?

    func retainMarker(_ info: NMCMarkerInfo) -> NMFMarker? {
        let marker = SRMarker()
        if let mapView {
            marker.showInfoWindow(on: mapView)
        }
        return marker
    }

    func releaseMarker(_ info: NMCMarkerInfo, _ marker: NMFMarker) {
        (marker as? SRMarker)?.hideInfoWindow()
    }
}
