//
//  NearbySheet.swift
//  saerok
//
//  Created by HanSeung on 8/13/25.
//


import SwiftUI

struct NearbySheet: View {
    var address: String
    var item: [Local.NearbyCollectionSummary]
    let onTap: (_ item: Local.NearbyCollectionSummary) -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack(spacing: 4) {
                Image.SRIconSet.pin
                    .frame(.defaultIconSize)
                Text("\(address)")
                    .font(.SRFontSet.subtitle2)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 18)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if item.isEmpty {
                emptyView
            } else {
                content
            }
        }
        .background(Color.srLightGray)
    }
    
    private var content: some View {
        ScrollView {
            LazyVStack(spacing: 7) {
                ForEach(item, id: \.collectionId) { item in
                    Button {
                        onTap(item)
                    } label: {
                        NearbyCell(item: item)
                    }
                    .buttonStyle(.plain)
                }
                Color.clear
                    .frame(height: 180)
            }
            .padding(9)
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 32) {
            VStack(spacing: 5) {
                Text("지금은 고요한 숲처럼 조용하네요.")
                    .font(.SRFontSet.subtitle1_2)
                Text("아직 이 주변에 올라온 새록이 없어요.")
                    .font(.SRFontSet.body2)
                    .foregroundStyle(Color.srDarkGray)
            }
            Image(.logoBack)
                .renderingMode(.template)
                .resizable()
                .foregroundStyle(.srWhite)
                .frame(width: 116, height: 128)
        }
        .padding(.top, 178)
    }
}


