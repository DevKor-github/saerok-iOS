//
//  CollectionHeaderView.swift
//  saerok
//
//  Created by HanSeung on 6/6/25.
//


import SwiftUI

struct CollectionHeaderView: View {
    var collectionCount: Int
    var isGuest: Bool = false
    let addButtonTapped: () -> Void
    
    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                Text(String(collectionCount))
                    .font(.SRFontSet.heavy)
                    .fontWeight(.semibold)
                    .foregroundStyle(.splash)
                Text("종의 새가 새록에 담겨있어요.")
                    .font(.SRFontSet.caption1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            addButton
        }
        .frame(height: 170)
        .padding(.horizontal, SRSpacing.screenHorizontal)
        .padding(.top, SRSpacing.screenHorizontal)
        .padding(.bottom, 8)
    }
    
    var addButton: some View {
        Button(action: addButtonTapped) {
            Image(isGuest ? .floatingButtonInactive : .floatingButton)
                .resizable()
                .srStyled(.floatingButton())
        }
    }
}
