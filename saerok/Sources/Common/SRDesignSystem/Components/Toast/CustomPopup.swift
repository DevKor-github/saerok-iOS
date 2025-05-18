//
//  CustomPopup.swift
//  saerok
//
//  Created by HanSeung on 5/13/25.
//


import SwiftUI

struct PopupButtonConfig<Style: ButtonStyle> {
    let title: String
    let action: () -> Void
    let style: Style
}

struct CustomPopup<Leading: ButtonStyle, Trailing: ButtonStyle>: View {
    let title: String
    let message: String
    let leading: PopupButtonConfig<Leading>
    let trailing: PopupButtonConfig<Trailing>
    
    var body: some View {
        VStack(spacing: 0) {
            Image.SRIconSet.alert
                .frame(.defaultIconSizeLarge)
                .padding(.bottom, 15)
            
            VStack(alignment: .center, spacing: 6) {
                Text(title)
                    .font(.SRFontSet.body3)
                Text(message)
                    .font(.SRFontSet.body2)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 20)

            
            
            HStack {
                Button(leading.title, action: leading.action)
                    .buttonStyle(leading.style)
                Button(trailing.title, action: trailing.action)
                    .buttonStyle(trailing.style)
            }
        }
        .padding()
        .frame(maxWidth: 300)
        .background(Color.srWhite)
        .cornerRadius(10)
        .padding()
    }
}
