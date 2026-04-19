import Foundation

protocol MapRepository {
    func searchPlaces(keyword: String) async throws -> DTO.KakaoSearchResponse
    func fetchAddress(longitude: Double, latitude: Double) async throws -> DTO.KakaoAddressResponse
    func fetchNearbyCollections(_ request: Local.NearbyRequest) async throws -> [Local.NearbyCollectionSummary]
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
}
