//
//  DateFormView.swift
//  saerok
//
//  Created by HanSeung on 5/13/25.
//


import SwiftUI

extension AddCollectionItemView {
    struct DateFormView: View {
        @Binding var date: Date?
        @State var isDateSelecting: Bool = false
        @FocusState var isFocused: Bool

        var body: some View {
            VStack(alignment: .leading) {
                Text("발견 일시")
                    .font(.SRFontSet.caption1)
                    .padding(.horizontal, 10)
                
                Text(date?.toFullString ?? "날짜를 선택해주세요")
                    .foregroundStyle(date != nil ? .primary : .tertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
                    .padding(.trailing, 10)
                    .frame(height: Constants.formHeight)
                    .srStyled(.textField(isFocused: $isFocused))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isDateSelecting ? Color.main : .border, lineWidth: 2)
                    )
                    .onTapGesture {
                        withAnimation {
                            isDateSelecting.toggle()
                        }
                    }

                if isDateSelecting {
                    DatePicker("", selection: Binding(
                        get: { date ?? Date() },
                        set: {
                            date = $0
                            isDateSelecting.toggle()
                        }
                    ), displayedComponents: .date)
                    .datePickerStyle(.graphical)
                }
            }
        }
    }
}
