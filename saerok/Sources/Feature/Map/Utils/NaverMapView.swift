//
//  NaverMapView.swift
//  saerok
//
//  Created by HanSeung on 5/6/25.
//


import CoreLocation
import NMapsMap
import SwiftUI

struct NaverMapView: View {
    @Binding var coord: (Double, Double)
    @ObservedObject var controller: MapController
    
    let showCenter: Bool
    
    init(showCenter: Bool = true, coord: Binding<(Double, Double)>, controller: MapController) {
        self.showCenter = showCenter
        self._coord = coord
        self.controller = controller
    }
    
    var body: some View {
        ZStack {
            if showCenter {
                VStack(spacing: 2) {
                    Image(.marker)
                        .resizable()
                        .frame(width: 51, height: 65.6)
                }
                .zIndex(1)
            }
            
            NaverMapContainer(controller: controller, coord: $coord)
                .edgesIgnoringSafeArea(.vertical)
        }
        .ignoresSafeArea(.keyboard)
    }
}
