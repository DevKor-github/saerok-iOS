//
//  EnumSelectionSheet.swift
//  saerok
//
//  Created by HanSeung on 4/15/25.
//


import SwiftUI

extension View {
    func sheetEnumPicker<T: Hashable & RawRepresentable & CaseIterable>(
        isPresented: Binding<Bool>,
        title: String,
        selection: Binding<Set<T>>,
        presentationDetents: Set<PresentationDetent>
    ) -> some View where T.RawValue == String {
        self.sheet(isPresented: isPresented) {
            EnumSelectionSheet(
                isPresented: isPresented,
                selection: selection,
                title: title,
                presentationDetents: presentationDetents
            )
        }
    }
}

private struct EnumSelectionSheet<T: Hashable & RawRepresentable & CaseIterable>: View where T.RawValue == String {
    @Binding var isPresented: Bool
    @Binding var selection: Set<T>

    let title: String
    let allOptions: [T] = Array(T.allCases)
    let presentationDetents: Set<PresentationDetent>

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.SRFontSet.headline2)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 15),
                GridItem(.flexible(), spacing: 15)
            ], spacing: 15) {
                ForEach(allOptions, id: \.rawValue) { item in
                    HStack {
                        Text(item.rawValue)
                            .foregroundColor(selection.contains(item) ? .white : .primary)
                        Spacer()
                        Image(systemName: selection.contains(item) ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(selection.contains(item) ? .white : .srGray)
                    }
                    .padding()
                    .background(selection.contains(item) ? Color.main : Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selection.toggle(item)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .presentationDetents(presentationDetents)
    }
}
