//
//  FilterButton.swift
//  saerok
//
//  Created by HanSeung on 4/22/25.
//


import SwiftUI

struct FilterButton<T: Hashable & RawRepresentable & CaseIterable>: View where T.RawValue == String {
    let icon: Image.SRIconSet
    let iconSelected: Image.SRIconSet
    let placeholder: String
    let title: String
    @Binding var isPresented: Bool
    @Binding var selection: Set<T>
    let detents: Set<PresentationDetent>
    let style: EnumPickerStyle

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
                (isActive ? iconSelected : icon)
                    .frame(.defaultIconSize, tintColor: isActive ? .srWhite : .splash)
                Text(
                    isActive
                    ? selection.map(\.rawValue).joined(separator: " • ")
                    : placeholder
                )
                .font(.SRFontSet.body1)
            }
        }
        .srStyled(.filterButton(isActive: isActive))
        .animation(.interactiveSpring, value: text)
        .sheetEnumPicker(
            isPresented: $isPresented,
            title: title,
            selection: $selection,
            presentationDetents: detents,
            style: style
        )
    }
}

#Preview {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    appDelegate.rootView
}
