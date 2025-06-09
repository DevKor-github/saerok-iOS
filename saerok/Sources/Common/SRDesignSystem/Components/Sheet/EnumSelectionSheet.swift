//
//  EnumSelectionSheet.swift
//  saerok
//
//  Created by HanSeung on 4/15/25.
//


import SwiftUI


enum EnumPickerStyle {
    case compact
    case adaptive
    case birdSize
}


extension View {
    func sheetEnumPicker<T: Hashable & RawRepresentable & CaseIterable>(
        isPresented: Binding<Bool>,
        title: String,
        selection: Binding<Set<T>>,
        presentationDetents: Set<PresentationDetent>,
        style: EnumPickerStyle
    ) -> some View where T.RawValue == String {
        self.sheet(isPresented: isPresented) {
            EnumSelectionSheet(
                isPresented: isPresented,
                selection: selection,
                title: title,
                presentationDetents: presentationDetents,
                style: style
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
    let style: EnumPickerStyle

    private let gridColumns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]
    
    var body: some View {
        VStack(spacing: 18) {
            header
            
            switch style {
            case .adaptive:
                if allOptions.count > 4 {
                    selectButtons
                }
                AdaptiveLeftAlignedGrid(
                    items: allOptions,
                    minCellWidth: 84,
                    spacing: 15
                ) { item in
                    gridItemView(for: item, fixed: false)
                }
                
            case .compact:
                LazyVGrid(columns: gridColumns, spacing: 15) {
                    ForEach(allOptions, id: \.rawValue) { item in
                        gridItemView(for: item)
                    }
                }
            
            case .birdSize:
                if T.self == BirdSize.self {
                    HStack(alignment: .bottom, spacing: 0) {
                        ForEach(allOptions, id: \.rawValue) { item in
                            if let item = item as? BirdSize {
                                birdSizeOptionView(item)
                            }
                        }
                    }
                } else {
                    Text("")
                }
            }
            
            Spacer()
            Divider()
            Button("완료") {
                isPresented.toggle()
            }
            .bold()
            .foregroundStyle(.splash)
        }
        .padding()
        .presentationDetents(presentationDetents)
    }
    
    private var header: some View {
        ZStack {
            Text(title)
                .font(.SRFontSet.headline2)
            HStack {
                Spacer()
                Button {
                    isPresented.toggle()
                } label: {
                    Image.SRIconSet.xmarkCircle.frame(.defaultIconSize)
                }
            }
        }
        .padding(12)
    }
    
    private var selectButtons: some View {
        HStack(spacing: 23) {
            Button {
                selection = Set(allOptions)
            } label: {
                (selection.count == allOptions.count ? Image(.radioSelected) : Image(.radio))
                Text("전체선택")
            }
            
            Button {
                selection.removeAll()
            } label: {
                (!selection.isEmpty ? Image(.radio) : Image(.radioSelected))
                Text("전체해제")
            }
            
            Spacer()
        }
        .font(.SRFontSet.body2)
        .foregroundStyle(.black)
    }

    @ViewBuilder
    private func gridItemView(for item: T, fixed: Bool = true) -> some View {
        HStack(spacing: 10) {
            Text(item.rawValue)
                .font(.SRFontSet.body1)
                .foregroundColor(selection.contains(item) ? .white : .primary)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
            if fixed {
                Spacer()
            }
            (selection.contains(item) ? Image.SRIconSet.checkboxMiniCheckedReverse : .checkboxMiniDefault)
                .frame(.defaultIconSize)
        }
        .padding()
        .background(selection.contains(item) ? Color.main : Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture {
            selection.toggle(item)
        }
    }
    
    @ViewBuilder
    private func birdSizeOptionView(_ item: BirdSize) -> some View {
        if item != .kayak {
            Spacer()
        }
        VStack {
            item.image
            (selection.contains(item as! T) ? Image(.checkboxMiniActive) : Image(.checkboxMiniDefault))
            Text(item.rawValue)
                .font(.SRFontSet.body1)
            Text(item.lengthDescription)
                .font(.SRFontSet.caption1)
                .foregroundStyle(.secondary)
        }
        .onTapGesture {
            selection.toggle(item as! T)
        }
    }
}
