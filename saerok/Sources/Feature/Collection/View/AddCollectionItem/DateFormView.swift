//
//  DateFormView.swift
//  saerok
//
//  Created by HanSeung on 5/13/25.
//


import SwiftUI

struct DateFormView: View {
    let title: String
    @Binding var date: Date
    @State var isDateSelecting: Bool = false
    @FocusState var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.SRFontSet.caption1)
                .padding(.horizontal, 10)
            
            Text(date.toFullString)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
                .padding(.trailing, 10)
                .frame(height: 44)
                .srStyled(.textField(isFocused: $isFocused))
                .overlay(
                    RoundedRectangle(cornerRadius: 17)
                        .strokeBorder(isDateSelecting ? Color.main : .border, lineWidth: 2)
                )
                .onTapGesture {
                    withAnimation {
                        isDateSelecting.toggle()
                    }
                }
            
            if isDateSelecting {
                DatePicker("", selection: Binding(
                    get: { date },
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

