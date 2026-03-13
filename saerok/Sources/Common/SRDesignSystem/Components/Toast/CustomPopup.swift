//
//  CustomPopup.swift
//  saerok
//
//  Created by HanSeung on 5/13/25.
//


import SwiftUI

struct PopupConfig {
    let title: String
    let message: String
    let buttons: PopupButtonLayout
}

enum PopupButtonLayout {
    case single(PopupButtonConfig)
    case double(PopupButtonConfig, PopupButtonConfig)
}

struct PopupButtonConfig {
    let title: String
    let style: AlertStyle
    let action: () -> Void
}

struct CustomPopup: View {
    let title: String
    let message: String
    let buttons: PopupButtonLayout
    
    var body: some View {
        VStack(spacing: 0) {
            Image.SRIconSet.alert
                .frame(.defaultIconSizeLarge, tintColor: .splash)
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
            
            buttonSection
        }
        .padding()
        .frame(maxWidth: 300)
        .background(Color.srWhite)
        .cornerRadius(20)
        .padding()
    }
    
    @ViewBuilder
    private var buttonSection: some View {
        switch buttons {
        case .single(let button):
            popupButton(button)
                .frame(maxWidth: .infinity)
            
        case .double(let leading, let trailing):
            HStack {
                popupButton(leading)
                popupButton(trailing)
            }
        }
    }
    
    @ViewBuilder
    private func popupButton(_ config: PopupButtonConfig) -> some View {
        Button(config.title, action: config.action)
            .srStyled(.alert(config.style))
    }
}

extension View {
    func customPopup(
        isPresented: Binding<Bool>,
        config: PopupConfig?
    ) -> some View {
        ZStack {
            self

            if isPresented.wrappedValue, let config {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isPresented.wrappedValue = false
                    }
                    .transition(.opacity)
                    .zIndex(1)

                CustomPopup(
                    title: config.title,
                    message: config.message,
                    buttons: config.buttons
                )
                .transition(.asymmetric(insertion: .scale, removal: .opacity))
                .zIndex(2)
            }
        }
        .animation(.spring(duration: 0.2), value: isPresented.wrappedValue)
    }
}
