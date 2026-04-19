//
//  TextFieldStyle.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//


import SwiftUI

struct SRTextFieldStyle: ViewModifier {
    var isFocused: FocusState<Bool>.Binding
    let alwaysFocused: Bool
    let tintColor: Color
    
    init(isFocused: FocusState<Bool>.Binding, alwaysFocused: Bool = false, tintColor: Color = .main) {
        self.isFocused = isFocused
        self.alwaysFocused = alwaysFocused
        self.tintColor = tintColor
    }
    
    func body(content: Content) -> some View {
        content
            .font(.SRFontSet.body2)
            .autocorrectionDisabled()
            .focused(isFocused)
            .background(.srWhite)
            .clipShape(RoundedRectangle(cornerRadius: 17))
            .overlay(
                RoundedRectangle(cornerRadius: 17)
                    .strokeBorder(!alwaysFocused ? (isFocused.wrappedValue ? tintColor : Color.border) : tintColor, lineWidth:2)
            )
    }
}

#Preview {
    SRTextFieldStylePreview()
}

private struct SRTextFieldStylePreview: View {
    @FocusState private var isFocused1: Bool
    @FocusState private var isFocused2: Bool
    @FocusState private var isFocused3: Bool
    @FocusState private var isFocused4: Bool
    
    @State private var text1 = ""
    @State private var text2 = "Sample text"
    @State private var text3 = ""
    @State private var text4 = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Default (Unfocused)")
                        .font(.SRFontSet.caption2)
                        .foregroundStyle(.gray)
                    TextField("Enter text", text: $text1)
                        .padding()
                        .modifier(SRTextFieldStyle(isFocused: $isFocused1))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Focused (Main Color)")
                        .font(.SRFontSet.caption2)
                        .foregroundStyle(.gray)
                    TextField("Tap to focus", text: $text2)
                        .padding()
                        .modifier(SRTextFieldStyle(isFocused: $isFocused2))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Always Focused (Main Color)")
                        .font(.SRFontSet.caption2)
                        .foregroundStyle(.gray)
                    TextField("Always shows main color border", text: $text3)
                        .padding()
                        .modifier(SRTextFieldStyle(isFocused: $isFocused3, alwaysFocused: true))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Custom Tint Color (Red)")
                        .font(.SRFontSet.caption2)
                        .foregroundStyle(.gray)
                    TextField("Custom border color", text: $text4)
                        .padding()
                        .modifier(SRTextFieldStyle(isFocused: $isFocused4, tintColor: .red))
                }
                
                Spacer()
            }
            .padding()
        }
        .background(Color(.systemGray6))
    }
}
