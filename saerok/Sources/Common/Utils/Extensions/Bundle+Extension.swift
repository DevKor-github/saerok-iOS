//
//  Bundle+Extension.swift
//  saerok
//
//  Created by HanSeung on 5/20/25.
//


import Foundation

extension Bundle {
    var kakaoAPIKey: String {
        return infoDictionary?["KAKAO_API_KEY"] as? String ?? ""
    }
    
    var kakaoAppID: String {
        return infoDictionary?["KAKAO_NATIVE_APP_KEY"] as? String ?? ""
    }
}
