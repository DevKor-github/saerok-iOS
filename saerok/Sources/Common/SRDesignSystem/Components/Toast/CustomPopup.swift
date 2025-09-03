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

struct CustomPopup<Leading: ButtonStyle, Trailing: ButtonStyle, Center: ButtonStyle>: View {
    let title: String
    let message: String
    let leading: PopupButtonConfig<Leading>?
    let trailing: PopupButtonConfig<Trailing>?
    let center: PopupButtonConfig<Center>?
    
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
        if let center = center {
            Button(center.title, action: center.action)
                .buttonStyle(center.style)
                .frame(maxWidth: .infinity)
        } else {
            HStack {
                if let leading = leading {
                    Button(leading.title, action: leading.action)
                        .buttonStyle(leading.style)
                }
                Spacer()
                if let trailing = trailing {
                    Button(trailing.title, action: trailing.action)
                        .buttonStyle(trailing.style)
                }
            }
        }
    }
}

extension View {
    func customPopup<Leading: ButtonStyle, Trailing: ButtonStyle, Center: ButtonStyle>(
        isPresented: Binding<Bool>,
        config: @escaping () -> CustomPopup<Leading, Trailing, Center>
    ) -> some View {
        ZStack {
            self

            if isPresented.wrappedValue {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isPresented.wrappedValue = false
                    }
                    .transition(.opacity)
                    .zIndex(1)

                config()
                    .transition(.asymmetric(insertion: .scale, removal: .opacity))
                    .zIndex(2)
            }
        }
        .animation(.spring(duration: 0.2), value: isPresented.wrappedValue)
    }
}

extension View {
    func customPopup(
        isPresented: Binding<Bool>,
        config: @escaping () -> AnyView
    ) -> some View {
        ZStack {
            self

            if isPresented.wrappedValue {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isPresented.wrappedValue = false
                    }
                    .transition(.opacity)
                    .zIndex(1)

                config()
                    .transition(.asymmetric(insertion: .scale, removal: .opacity))
                    .zIndex(2)
            }
        }
        .animation(.spring(duration: 0.2), value: isPresented.wrappedValue)
    }
}
