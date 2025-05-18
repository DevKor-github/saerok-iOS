//
//  MapView.swift
//  saerok
//
//  Created by HanSeung on 5/6/25.
//


import CoreLocation
import NMapsMap
import SwiftUI

struct MapView: View {
    @Binding var coord: (Double, Double)
    @ObservedObject var controller: MapController
    
    var body: some View {
        ZStack {
            VStack(spacing: 2) {
                Image(.marker)
                    .resizable()
                    .frame(width: 40, height: 56)
            }
            .zIndex(1)
            
            VStack {
                Spacer()
                Button(action: {
                    controller.moveToUserLocation()
                }, label: {
                    Image(.mylocation)
                        .resizable()
                        .frame(width: 42, height: 42)
                })
                .frame(alignment: .bottomLeading)
                .padding(.horizontal, SRDesignConstant.defaultPadding)
                .frame(maxWidth: .infinity, alignment: .bottomLeading)
            }
            .zIndex(1)
            
            NaverMapContainer(controller: controller, coord: $coord)
                .edgesIgnoringSafeArea(.vertical)
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    @Previewable @State var lo = (37.5665, 126.9780)
    @Previewable @State var controller = MapController()
    MapView(coord: $lo, controller: controller)
}
