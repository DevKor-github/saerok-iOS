//
//  BirdNameFormView.swift
//  saerok
//
//  Created by HanSeung on 5/13/25.
//

import SwiftUI

extension CollectionFormView {
    struct BirdNameFormView: View {
        @Bindable private var draft: Local.CollectionDraft
        @FocusState private var isFocused: Bool
        
        private let onTapFindBird: () -> Void
        private let onToggleUnknownBird: () -> Void
        
        init(draft: Local.CollectionDraft, onTapFindBird: @escaping () -> Void, onToggleUnknownBird: @escaping () -> Void) {
            self.draft = draft
            self.onTapFindBird = onTapFindBird
            self.onToggleUnknownBird = onToggleUnknownBird
        }
        
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
                HStack(spacing: 6) {
                    Text(draft.bird?.name ?? "새 이름을 입력해주세요")
                        .foregroundStyle(draft.bird != nil ? .primary : .tertiary)
                        .lineLimit(1)

                    if draft.bird?.isProtected == true {
                        protectedSpeciesTag
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image.SRIconSet.searchSecondary
                    .frame(.default)
                    .foregroundStyle(.border)
                    .padding(.trailing, 4)
            }
            .padding(.leading, 20)
            .padding(.trailing, 10)
            .frame(height: Constants.formHeight)
            .srStyled(.textField(isFocused: $isFocused))
            .opacity(draft.isUnknownBird ? 0.4 : 1)
            .onTapGesture(perform: onTapFindBird)
            // coordinator.push(CollectionFormView.Route.findBird)
        }

        private var protectedSpeciesTag: some View {
            Text("보호종")
                .font(.SRFontSet.caption3_2)
                .foregroundStyle(.srGray)
                .padding(.horizontal, 3)
                .padding(.vertical, 1)
                .background(Color.srLightGray)
                .clipShape(RoundedRectangle(cornerRadius: 5))
        }
        
        private var unknownBirdButtonRow: some View {
            HStack {
                Spacer()
                Button {
                    onToggleUnknownBird()
                    draft.isUnknownBird.toggle()
                    draft.bird = nil
                } label: {
                    HStack(spacing: 5) {
                        (draft.isUnknownBird ? Image.SRIconSet.checkboxMiniChecked : Image.SRIconSet.checkboxMiniDefault)
                            .frame(.default)
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
