//
//  BannerView.swift
//  saerok
//
//  Created by HanSeung on 10/10/25.
//

import SwiftUI
import AdFitSDK

struct BannerView: View {
    @State private var orientation: UIDeviceOrientation = .portrait
    
    var body: some View {
        Group {
            if isProblematicOS {
                EmptyView()
            } else {
                AdFitBannerPresentableView(
                    clientId: Bundle.main.kakaoAdFitKey,
                    adUnitSize: "320x50"
                )
                .onSizeThatFits(orientation: $orientation)
            }
        }
    }
    
    private var isProblematicOS: Bool {
        let v = ProcessInfo.processInfo.operatingSystemVersion
        return v.majorVersion == 18 &&
               v.minorVersion == 3 &&
               v.patchVersion == 1
    }
}
