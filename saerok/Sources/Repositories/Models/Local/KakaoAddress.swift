//
//  KakaoAddress.swift
//  saerok
//
//  Created by HanSeung on 5/13/25.
//


extension Local {
    struct KakaoAddress {
        let address: String
        let roadAddress: String
        
        static func toLocal(dto: DTO.KakaoAddress) -> Local.KakaoAddress {
            Local.KakaoAddress(
                address: dto.address?.addressName ?? "주소 없음",
                roadAddress: dto.roadAddress?.addressName ?? "도로명 주소 없음"
            )
        }
    }
}

extension Array where Element == DTO.KakaoAddress {
    func toLocal() -> [Local.KakaoAddress] {
        self.compactMap { Local.KakaoAddress.toLocal(dto: $0) }
    }
}
