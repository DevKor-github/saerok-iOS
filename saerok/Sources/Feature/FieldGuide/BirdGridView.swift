//
//  BirdGridView.swift
//  saerok
//
//  Created by HanSeung on 5/15/25.
//


import SwiftUI

struct BirdGridView: View {
    let birds: [Local.Bird]
    let onTap: (Local.Bird) -> Void
    @Binding var showPopup: Bool

    init(birds: [Local.Bird], onTap: @escaping (Local.Bird) -> Void, showPopup: Binding<Bool>) {
        self.birds = birds
        self.onTap = onTap
        self._showPopup = showPopup
    }

    struct PressScaleStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
        }
    }

    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 7),
                GridItem(.flexible(), spacing: 7)
            ],
            spacing: 7
        ) {
            ForEach(birds) { bird in
                Button {
                    onTap(bird)
                } label: {
                    BirdCardView(bird, showPopup: $showPopup)
                }
                .buttonStyle(PressScaleStyle())
            }

            Group {
                Rectangle()
                Rectangle()
                Rectangle()
                Rectangle()
            }
            .foregroundStyle(.clear)
            .frame(height: 198)
        }
        .padding(.horizontal ,9)
        .background(Color.srLightGray)
    }
}

#Preview {
    @Previewable @State var showPopup = false
    return BirdGridView(birds: Local.Bird.mockData, onTap: {_ in }, showPopup: $showPopup)
}
