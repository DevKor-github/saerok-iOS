//
//  NoteFormView.swift
//  saerok
//
//  Created by HanSeung on 5/13/25.
//


import SwiftUI

extension CollectionFormView {
    struct NoteFormView: View {
        @ObservedObject var draft: Local.CollectionDraft
        @FocusState var isFocused: Bool

        var body: some View {
            VStack(alignment: .leading) {
                Text("한 줄 평")
                    .font(.SRFontSet.caption1)
                    .padding(.horizontal, 10)
                
                TextField("한 줄 평을 입력해주세요", text: $draft.note)
                    .padding(20)
                    .frame(height: Constants.formHeight)
                    .srStyled(.textField(isFocused: $isFocused))
                    .overlay(alignment: .topTrailing) {
                        Text("(\(draft.note.count)/\(Constants.maxNoteLength))")
                            .font(.SRFontSet.caption1)
                            .foregroundColor(.secondary)
                            .padding(.top, 48)
                    }
                    .onChange(of: draft.note) { _, newValue in
                        if newValue.count > Constants.maxNoteLength {
                            draft.note = String(newValue.prefix(Constants.maxNoteLength))
                        }
                    }
            }
        }
    }
}
