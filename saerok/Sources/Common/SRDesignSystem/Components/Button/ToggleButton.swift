//
//  ToggleButton.swift
//  saerok
//
//  Created by HanSeung on 8/14/25.
//


import SwiftUI

struct ToggleButton: View {
    @Binding var isOff: Bool
    let buttonAction: () -> Void
    
    var body: some View {
        Button(action: {
            buttonAction()
        }) {
            ZStack(alignment: isOff ? .leading : .trailing) {
                RoundedRectangle(cornerRadius: .infinity)
                    .fill(isOff ? Color.whiteGray : Color.main)
                    .frame(width: 55, height: 30)
                
                Circle()
                    .fill(.srWhite)
                    .frame(width: 25, height: 25)
                    .padding(2.5)
            }
        }
        .buttonStyle(.plain)
    }
}
