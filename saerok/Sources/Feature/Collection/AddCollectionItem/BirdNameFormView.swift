//
//  BirdNameFormView.swift
//  saerok
//
//  Created by HanSeung on 5/13/25.
//


import SwiftUI

extension AddCollectionItemView {
    struct BirdNameFormView: View {
        var selectedBird: Local.Bird?
        @Binding var path: NavigationPath
        @FocusState var isFocused: Bool
        
        var body: some View {
            VStack(alignment: .leading) {
                Text("새 이름")
                    .font(.SRFontSet.caption1)
                    .padding(.horizontal, 10)
                
                HStack {
                    Text(selectedBird?.name ?? "새 이름을 입력해주세요")
                        .foregroundStyle(selectedBird != nil ? .primary : .tertiary)
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
                path.append(AddCollectionItemView.Route.findBird)
            }
        }
    }
}
