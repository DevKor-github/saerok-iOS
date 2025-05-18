//
//  LocationFormView.swift
//  saerok
//
//  Created by HanSeung on 5/13/25.
//


import SwiftUI

extension AddCollectionItemView {
    struct LocationFormView: View {
        @Binding var selectedCoord: (Double, Double)
        @Binding var path: NavigationPath
        
        var address: String

        @FocusState var isFocused: Bool

        var body: some View {
            VStack(alignment: .leading) {
                Text("발견 장소")
                    .font(.SRFontSet.caption1)
                    .padding(.horizontal, 10)

                HStack {
                    Text(selectedCoord == (0,0) ? "장소를 선택해주세요" : address)
                        .lineLimit(1)
                        .foregroundStyle(selectedCoord != (0,0) ? .primary : .tertiary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Image.SRIconSet.searchSecondary.frame(.defaultIconSize)
                        .foregroundStyle(.border)
                        .padding(.trailing, 4)
                }
                .padding(.leading, 20)
                .padding(.trailing, 10)
                .frame(height: Constants.formHeight)
                .srStyled(.textField(isFocused: $isFocused))
            }
            .onTapGesture {
                path.append(Route.findLocation)
            }
        }
    }
}
