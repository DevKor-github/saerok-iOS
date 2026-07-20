import Foundation
import Testing
@testable import saerok

// MARK: - MapInteractor Tests

@Suite("MapInteractor")
struct MapInteractorTests {

    // MARK: address

    @Test("좌표에 해당하는 주소 결과가 없으면 빈 문자열을 반환한다")
    func addressReturnsEmptyWhenNoDocuments() async throws {
        let interactor = MapInteractorImpl(repository: StubMapRepository(addressDocuments: []))
        let result = try await interactor.address(for: 127.0, latitude: 37.5)
        #expect(result == "")
    }

    @Test("첫 번째 주소 결과의 행정구역을 공백으로 이어 붙여 반환한다")
    func addressJoinsRegionNames() async throws {
        let address = DTO.Address.stub(region1: "서울특별시", region2: "강남구", region3: "역삼동")
        let document = DTO.KakaoAddress(roadAddress: nil, address: address)
        let interactor = MapInteractorImpl(repository: StubMapRepository(addressDocuments: [document]))
        let result = try await interactor.address(for: 127.0, latitude: 37.5)
        #expect(result == "서울특별시 강남구 역삼동")
    }

    @Test("도로명 주소만 있고 지번 주소가 없으면 빈 문자열을 반환한다")
    func addressReturnsEmptyWhenAddressIsNil() async throws {
        let document = DTO.KakaoAddress(roadAddress: nil, address: nil)
        let interactor = MapInteractorImpl(repository: StubMapRepository(addressDocuments: [document]))
        let result = try await interactor.address(for: 127.0, latitude: 37.5)
        #expect(result == "")
    }

    // MARK: search

    @Test("장소를 검색하면 결과가 Local.KakaoPlace 목록으로 변환되어 반환된다")
    func searchReturnsCorrectPlaceCount() async throws {
        let places = [DTO.KakaoPlace.stub(id: "1"), .stub(id: "2"), .stub(id: "3")]
        let interactor = MapInteractorImpl(repository: StubMapRepository(searchDocuments: places))
        let result = try await interactor.search(keyword: "공원")
        #expect(result.map(\.id) == [1, 2, 3])
        #expect(result.map(\.placeName) == ["장소1", "장소2", "장소3"])
    }

    @Test("장소 검색 결과가 없으면 빈 배열을 반환한다")
    func searchReturnsEmptyWhenNoResults() async throws {
        let interactor = MapInteractorImpl(repository: StubMapRepository(searchDocuments: []))
        let result = try await interactor.search(keyword: "존재하지않는장소")
        #expect(result.isEmpty)
    }

    // MARK: - Stub

    private struct StubMapRepository: MapRepository {
        var searchDocuments: [DTO.KakaoPlace] = []
        var addressDocuments: [DTO.KakaoAddress] = []

        func searchPlaces(keyword: String) async throws -> DTO.KakaoSearchResponse {
            .init(
                meta: .init(pageableCount: searchDocuments.count, totalCount: searchDocuments.count, isEnd: true),
                documents: searchDocuments
            )
        }

        func fetchAddress(longitude: Double, latitude: Double) async throws -> DTO.KakaoAddressResponse {
            .init(meta: .init(totalCount: addressDocuments.count), documents: addressDocuments)
        }

        func fetchNearbyCollections(_ request: Local.NearbyRequest) async throws -> [Local.NearbyCollectionSummary] { [] }

        func fetchRecentMapSearches() async throws -> [Local.RecentMapSearch] { [] }
        func upsertRecentPlaceSearch(_ place: Local.KakaoPlace) async throws {}
        func deleteRecentMapSearch(id: UUID) async throws {}
    }
}

// MARK: - Test Helpers

private extension DTO.KakaoPlace {
    static func stub(id: String) -> Self {
        .init(
            placeName: "장소\(id)",
            distance: "0",
            placeURL: "",
            categoryName: "",
            addressName: "",
            roadAddressName: "",
            id: id,
            phone: "",
            categoryGroupCode: "",
            categoryGroupName: "",
            x: "127.0",
            y: "37.5"
        )
    }
}

private extension DTO.Address {
    static func stub(region1: String, region2: String, region3: String) -> Self {
        .init(
            addressName: "\(region1) \(region2) \(region3)",
            region1DepthName: region1,
            region2DepthName: region2,
            region3DepthName: region3,
            mountainYN: "N",
            mainAddressNo: "0",
            subAddressNo: ""
        )
    }
}
