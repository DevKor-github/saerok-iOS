//
//  KakaoSearchResponse.swift
//  saerok
//
//  Created by HanSeung on 5/8/25.
//


extension Local {
    struct KakaoPlace {
        let id: Int
        let placeName: String
        let address: String
        let roadAddress: String
        let category: String
        let latitude: Double
        let longtitude: Double
        
        static func toLocal(dto: DTO.KakaoPlace) -> Local.KakaoPlace {
            Local.KakaoPlace(
                id: Int(dto.id) ?? 0,
                placeName: dto.placeName,
                address: dto.roadAddressName,
                roadAddress: dto.roadAddressName,
                category: dto.categoryGroupName,
                latitude: Double(dto.y) ?? 0,
                longtitude: Double(dto.x) ?? 0
            )
        }
    }
    
}

extension Array where Element == DTO.KakaoPlace {
    func toLocal() -> [Local.KakaoPlace] {
        self.compactMap { Local.KakaoPlace.toLocal(dto: $0) }
    }
}
