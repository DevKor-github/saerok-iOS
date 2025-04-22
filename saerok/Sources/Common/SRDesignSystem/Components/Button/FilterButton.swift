//
//  FilterButton.swift
//  saerok
//
//  Created by HanSeung on 4/22/25.
//


import SwiftUI

struct FilterButton<T: Hashable & RawRepresentable & CaseIterable>: View where T.RawValue == String {
    let icon: Image
    let placeholder: String
    let title: String
    @Binding var isPresented: Bool
    @Binding var selection: Set<T>
    let detents: Set<PresentationDetent>

    var isActive: Bool {
        !selection.isEmpty
    }

    var text: String {
        isActive
            ? selection.map(\.rawValue).joined(separator: " • ")
            : placeholder
    }
    
    var body: some View {
        Button {
            isPresented.toggle()
        } label: {
            HStack(spacing: 4) {
                icon
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16)
                Text(
                    isActive
                    ? selection.map(\.rawValue).joined(separator: " • ")
                    : placeholder
                )
                .font(.SRFontSet.h3)
            }
        }
        .srStyled(.filterButton(isActive: isActive))
        .animation(.interactiveSpring, value: text)
        .sheetEnumPicker(
            isPresented: $isPresented,
            title: title,
            selection: $selection,
            presentationDetents: detents
        )
    }
}

#Preview {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    appDelegate.rootView
}
