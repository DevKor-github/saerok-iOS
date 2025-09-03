//
//  SRMarker.swift
//  saerok
//
//  Created by HanSeung on 7/8/25.
//


import NMapsMap

final class SRMarker: NMFMarker {
        
    var noteWindow = NMFInfoWindow()
    
    // MARK: - init
    
    override init() {
        super.init()
        setUI()
        setInfoWindow()
    }
}

// MARK: - UI & Layout

extension SRMarker {
    private func setUI() {
        self.iconImage = NMFOverlayImage(image: .circle)
        self.width = 60
        self.height = 60
        self.anchor = CGPoint(x: 0.5, y: 0.5)
        self.iconPerspectiveEnabled = true
    }
    
    func setInfoWindow() {
        let dataSource = InfoWindowImageDataSource()
        noteWindow.dataSource = dataSource
        noteWindow.maxZoom = 21
        noteWindow.minZoom = 14
        noteWindow.anchor = CGPoint(x: 0.5, y: 0.5)
    }
    
    func showInfoWindow(on mapView: NMFMapView?) {
        noteWindow.userInfo = self.userInfo
        noteWindow.touchHandler = self.touchHandler
        noteWindow.mapView = mapView
        noteWindow.open(with: self)
    }
    
    func hideInfoWindow() {
        noteWindow.close()
    }
}

class InfoWindowImageDataSource: NSObject, NMFOverlayImageDataSource {
    func view(with overlay: NMFOverlay) -> UIView {
        let noteText: String
        let nameText: String
        if let tag = overlay.userInfo["tag"] as? ItemData {
            noteText = tag.birdData.note
            nameText = tag.birdData.koreanName ?? "이름 모를 새"
        } else {
            noteText = ""
            nameText = "이름 모를 새"
        }

        let image = NoteBalloonRenderer.make(note: noteText, birdName: nameText)
        let size = image.size

        let imageView = UIImageView(frame: CGRect(origin: .zero, size: size))
        imageView.image = image
        return imageView
    }
}
