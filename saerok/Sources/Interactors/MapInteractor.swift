import Foundation

protocol MapInteractor {
    func search(keyword: String) async throws -> [Local.KakaoPlace]
    func address(for longitude: Double, latitude: Double) async throws -> String
    func fetchNearbyCollections(lat: Double, lng: Double, rad: Double, isMineOnly: Bool, isGuest: Bool) async throws -> [Local.NearbyCollectionSummary] 
}

struct MapInteractorImpl: MapInteractor {
    private let repository: MapRepository

    init(repository: MapRepository) {
        self.repository = repository
    }

    func search(keyword: String) async throws -> [Local.KakaoPlace] {
        let response = try await repository.searchPlaces(keyword: keyword)
        return response.documents.toLocal()
    }

    func address(for longitude: Double, latitude: Double) async throws -> String {
        let response = try await repository.fetchAddress(longitude: longitude, latitude: latitude)
        return response.documents.first?.address?.adrs ?? ""
    }
    
    func fetchNearbyCollections(lat: Double, lng: Double, rad: Double, isMineOnly: Bool, isGuest: Bool) async throws -> [Local.NearbyCollectionSummary] {
        let request = Local.NearbyRequest(
            latitude: lat,
            longitude: lng,
            radius: rad,
            isMineOnly: isMineOnly,
            isGuest: isGuest
        )
        return try await repository.fetchNearbyCollections(request)
    }
}

struct MockMapInteractorImpl: MapInteractor {
    func search(keyword: String) async throws -> [Local.KakaoPlace] { [] }
    
    func address(for longitude: Double, latitude: Double) async throws -> String { "" }
    
    func fetchNearbyCollections(lat: Double, lng: Double, rad: Double, isMineOnly: Bool, isGuest: Bool) async throws -> [Local.NearbyCollectionSummary] { [] }
}
