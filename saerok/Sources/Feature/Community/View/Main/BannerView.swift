//
//  BannerView.swift
//  saerok
//
//  Created by HanSeung on 10/10/25.
//

import SwiftUI
import AdFitSDK

struct BannerView: View {
    @State private var orientation: UIDeviceOrientation = .unknown
    
    var body: some View {
        AdFitBannerPresentableView(
            clientId: Bundle.main.kakaoAdFitKey,
            adUnitSize: "320x50"
        )
        .onSizeThatFits(orientation: $orientation)
    }
}
