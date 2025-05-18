//
//  KakaoAddressResponse.swift
//  saerok
//
//  Created by HanSeung on 5/14/25.
//


extension DTO {
    struct KakaoAddressResponse: Decodable {
        let meta: Meta
        let documents: [KakaoAddress]
        
        struct Meta: Decodable {
            let totalCount: Int
            
            enum CodingKeys: String, CodingKey {
                case totalCount = "total_count"
            }
        }
    }
    
    struct KakaoAddress: Decodable {
        let roadAddress: RoadAddress?
        let address: Address?
        
        enum CodingKeys: String, CodingKey {
            case roadAddress = "road_address"
            case address
        }
    }
    
    struct RoadAddress: Decodable {
        let addressName: String
        let region1DepthName: String
        let region2DepthName: String
        let region3DepthName: String
        let roadName: String
        let undergroundYN: String
        let mainBuildingNo: String
        let subBuildingNo: String
        let buildingName: String
        let zoneNo: String
        
        enum CodingKeys: String, CodingKey {
            case addressName = "address_name"
            case region1DepthName = "region_1depth_name"
            case region2DepthName = "region_2depth_name"
            case region3DepthName = "region_3depth_name"
            case roadName = "road_name"
            case undergroundYN = "underground_yn"
            case mainBuildingNo = "main_building_no"
            case subBuildingNo = "sub_building_no"
            case buildingName = "building_name"
            case zoneNo = "zone_no"
        }
    }
    
    struct Address: Decodable {
        let addressName: String
        let region1DepthName: String
        let region2DepthName: String
        let region3DepthName: String
        let mountainYN: String
        let mainAddressNo: String
        let subAddressNo: String
        
        enum CodingKeys: String, CodingKey {
            case addressName = "address_name"
            case region1DepthName = "region_1depth_name"
            case region2DepthName = "region_2depth_name"
            case region3DepthName = "region_3depth_name"
            case mountainYN = "mountain_yn"
            case mainAddressNo = "main_address_no"
            case subAddressNo = "sub_address_no"
        }
    }
}
