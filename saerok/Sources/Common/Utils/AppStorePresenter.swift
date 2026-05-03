//
//  AppStorePresenter.swift
//  saerok
//
//  Created by HanSeung on 9/14/25.
//


import SwiftUI
import StoreKit

struct AppStorePresenter {
    static func present(appID: String) {
        guard let root = UIApplication.shared.connectedScenes
                .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
                .first?.rootViewController else { return }
        
        let storeVC = SKStoreProductViewController()
        let parameters = [SKStoreProductParameterITunesItemIdentifier: appID]
        storeVC.loadProduct(withParameters: parameters, completionBlock: nil)
        root.present(storeVC, animated: true)
    }
}

@Observable
@MainActor
final class AppVersionChecker {
    var showUpdateAlert = false
    var appStoreURL = "https://apps.apple.com/us/app/%EC%83%88%EB%A1%9D-%EC%9D%BC%EC%83%81-%EC%86%8D%EC%9D%98-%ED%83%90%EC%A1%B0-%EC%9D%BC%EC%A7%80/id6744866662"
    
    func checkVersion() async {
        let lookupURL = "https://itunes.apple.com/lookup?bundleId=com.apu.saerok&country=kr"
        
        do {
            let (data, _) = try await URLSession.shared.data(from: URL(string: lookupURL)!)
            
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let results = json["results"] as? [[String: Any]],
               let appInfo = results.first,
               let latestVersion = appInfo["version"] as? String,
               let trackViewUrl = appInfo["trackViewUrl"] as? String
            {
                let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
                let currentMinor = currentVersion.split(separator: ".").prefix(2).joined(separator: ".")
                let latestMinor = latestVersion.split(separator: ".").prefix(2).joined(separator: ".")
                if currentMinor.compare(latestMinor, options: .numeric) == .orderedAscending {
                    appStoreURL = trackViewUrl
                    showUpdateAlert = true
                }
            }
        } catch { }
    }
}
