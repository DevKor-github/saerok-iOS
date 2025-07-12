//
//  BirdNameFormView.swift
//  saerok
//
//  Created by HanSeung on 5/13/25.
//


import SwiftUI

extension CollectionFormView {
    struct BirdNameFormView: View {
        @Environment(\.injected) var injected
        @ObservedObject var draft: Local.CollectionDraft
        @Binding var path: NavigationPath
        @FocusState var isFocused: Bool
        
        var body: some View {
            VStack(alignment: .leading, spacing: 7) {
                Text("새 이름")
                    .font(.SRFontSet.caption1)
                    .padding(.horizontal, 10)
                
                birdNameRow
                
                unknownBirdButtonRow
            }
            .frame(maxWidth: .infinity, alignment: .bottomTrailing)
        }
        
        // MARK: - Subviews
        
        private var birdNameRow: some View {
            HStack {
                Text(draft.bird?.name ?? "새 이름을 입력해주세요")
                    .foregroundStyle(draft.bird != nil ? .primary : .tertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image.SRIconSet.searchSecondary
                    .frame(.defaultIconSize)
                    .foregroundStyle(.border)
                    .padding(.trailing, 4)
            }
            .padding(.leading, 20)
            .padding(.trailing, 10)
            .frame(height: Constants.formHeight)
            .srStyled(.textField(isFocused: $isFocused))
            .opacity(draft.isUnknownBird ? 0.4 : 1)
            .onTapGesture {
                path.append(CollectionFormView.Route.findBird)
            }
        }
        
        private var unknownBirdButtonRow: some View {
            HStack {
                Spacer()
                Button {
                    injected.appState[\.routing.addCollectionItemView.selectedBird] = nil
                    draft.isUnknownBird.toggle()
                    draft.bird = nil
                } label: {
                    HStack(spacing: 5) {
                        (draft.isUnknownBird ? Image.SRIconSet.checkboxMiniChecked : Image.SRIconSet.checkboxMiniDefault)
                            .frame(.defaultIconSize)
                        Text("모르겠어요")
                            .font(.SRFontSet.body2)
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}
