import Foundation
import SwiftData

protocol MapRepository {
    func searchPlaces(keyword: String) async throws -> DTO.KakaoSearchResponse
    func fetchAddress(longitude: Double, latitude: Double) async throws -> DTO.KakaoAddressResponse
    func fetchNearbyCollections(_ request: Local.NearbyRequest) async throws -> [Local.NearbyCollectionSummary]

    // MARK: 검색 기록 (SwiftData)
    func fetchRecentMapSearches() async throws -> [Local.RecentMapSearch]
    func upsertRecentPlaceSearch(_ place: Local.KakaoPlace) async throws
    func deleteRecentMapSearch(id: UUID) async throws
}

extension MainRepository: MapRepository {
    func searchPlaces(keyword: String) async throws -> DTO.KakaoSearchResponse {
        try await networkService.performKakaoRequest(.keyword(keyword))
    }

    func fetchAddress(longitude: Double, latitude: Double) async throws -> DTO.KakaoAddressResponse {
        try await networkService.performKakaoRequest(
            .address(
                lng: longitude,
                lat: latitude
            )
        )        
    }
    
    func fetchNearbyCollections(
        _ request: Local.NearbyRequest
    ) async throws -> [Local.NearbyCollectionSummary] {
        let dtos: DTO.NearbyCollectionsResponse = try await networkService.performSRRequest(
            .nearbyCollections(
                lat: request.latitude,
                lng: request.longitude,
                radius: request.radius,
                isMineOnly: request.isMineOnly,
                isGuest: request.isGuest
            )
        )
        return dtos.items.map {
            Local.NearbyCollectionSummary.from(dto: $0)
        }
    }

    // MARK: - 검색 기록 (SwiftData)

    func fetchRecentMapSearches() async throws -> [Local.RecentMapSearch] {
        let descriptor = FetchDescriptor<Local.RecentMapSearchEntity>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor).map { $0.snapshot }
    }

    func upsertRecentPlaceSearch(_ place: Local.KakaoPlace) async throws {
        let placeKind = Local.MapSearchKind.place.rawValue
        let lat = place.latitude
        let lng = place.longitude
        let request = FetchDescriptor<Local.RecentMapSearchEntity>(
            predicate: #Predicate {
                $0.kindRaw == placeKind && $0.latitude == lat && $0.longitude == lng
            }
        )

        if let existing = try modelContext.fetch(request).first {
            existing.createdAt = .now
        } else {
            modelContext.insert(Local.RecentMapSearchEntity(place: place))
        }
        try modelContext.save()
    }

    func deleteRecentMapSearch(id: UUID) async throws {
        let request = FetchDescriptor<Local.RecentMapSearchEntity>(
            predicate: #Predicate { $0.uuid == id }
        )
        guard let entity = try modelContext.fetch(request).first else { return }
        modelContext.delete(entity)
        try modelContext.save()
    }
}
