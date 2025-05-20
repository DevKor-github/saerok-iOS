//
//  NoteFormView.swift
//  saerok
//
//  Created by HanSeung on 5/13/25.
//


import SwiftUI

extension AddCollectionItemView {
    struct NoteFormView: View {
        @Binding var note: String
        @FocusState var isFocused: Bool
        
        var body: some View {
            VStack(alignment: .leading) {
                Text("한 줄 평")
                    .font(.SRFontSet.caption1)
                    .padding(.horizontal, 10)
                
                TextField("한 줄 평을 입력해주세요", text: $note)
                    .padding(20)
                    .frame(height: Constants.formHeight)
                    .srStyled(.textField(isFocused: $isFocused))
                    .overlay(alignment: .topTrailing) {
                        Text("(\(note.count)/\(Constants.maxNoteLength))")
                            .font(.SRFontSet.caption1)
                            .foregroundColor(.secondary)
                            .padding(.top, 48)
                    }
                    .onChange(of: note) { _, newValue in
                        if newValue.count > Constants.maxNoteLength {
                            note = String(newValue.prefix(Constants.maxNoteLength))
                        }
                    }
            }
        }
    }
}
