//
//  CollectionDraft.swift
//  saerok
//
//  Created by HanSeung on 6/7/25.
//


import UIKit
import Foundation

extension Local {
    final class CollectionDraft: ObservableObject, Equatable {
        @Published var bird: Local.Bird?
        @Published var isUnknownBird: Bool
        @Published var image: UIImage?
        @Published var discoveredDate: Date
        @Published var coordinate: (Double, Double)
        @Published var address: String
        @Published var locationAlias: String
        @Published var note: String
        @Published var isVisible: Bool
        @Published var collectionID: Int?
        @Published private(set) var originalBirdId: Int?
        
        var submittable: Bool {
            (bird != nil || isUnknownBird)
            && image != nil
            && !note.isEmpty
            && !locationAlias.isEmpty
            && coordinate != (0, 0)
        }

        init(
            bird: Local.Bird? = nil,
            isUnknownBird: Bool = false,
            image: UIImage? = nil,
            discoveredDate: Date = .now,
            coordinate: (Double, Double) = (0, 0),
            address: String = "",
            locationAlias: String = "",
            note: String = "",
            isVisible: Bool = true,
            collectionID: Int?
        ) {
            self.bird = bird
            self.isUnknownBird = isUnknownBird
            self.image = image
            self.discoveredDate = discoveredDate
            self.coordinate = coordinate
            self.address = address
            self.locationAlias = locationAlias
            self.note = note
            self.isVisible = isVisible
            self.collectionID = collectionID
        }
        
        static func == (lhs: CollectionDraft, rhs: CollectionDraft) -> Bool {
            lhs.bird?.id == rhs.bird?.id
            && lhs.image == rhs.image
            && lhs.discoveredDate == rhs.discoveredDate
            && lhs.coordinate == rhs.coordinate
            && lhs.address == rhs.address
            && lhs.locationAlias == rhs.locationAlias
            && lhs.note == rhs.note
            && lhs.isUnknownBird == rhs.isUnknownBird
            && lhs.isVisible == rhs.isVisible
        }
    }
}

extension Local.CollectionDraft {
    func toDTO() -> DTO.CreateCollectionRequest {
        DTO.CreateCollectionRequest(
            birdId: bird?.id,
            discoveredDate: discoveredDate,
            latitude: coordinate.0,
            longitude: coordinate.1,
            locationAlias: locationAlias,
            address: address,
            note: note
        )
    }
    
    func toEditDTO(isBirdUpdated: Bool) -> DTO.EditCollectionMetadataRequest {
        .init(
            isBirdIdUpdated: isBirdUpdated,
            birdId: bird?.id,
            discoveredDate: discoveredDate.toUploadType,
            longitude: coordinate.1,
            latitude: coordinate.0,
            locationAlias: locationAlias,
            address: address,
            note: note
        )
    }
    
    static func fromDetail(_ detail: Local.CollectionDetail) -> Local.CollectionDraft {
        let draft = Local.CollectionDraft(
            isUnknownBird: detail.birdID == nil,
            discoveredDate: detail.discoveredDate,
            coordinate: detail.coordinate,
            address: detail.address,
            locationAlias: detail.locationAlias,
            note: detail.note,
            isVisible: detail.accessLevel == .publicAccess,
            collectionID: detail.id
        )
        draft.originalBirdId = detail.birdID
        return draft
    }
}
