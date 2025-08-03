//
//  SRToggleButton.swift
//  saerok
//
//  Created by HanSeung on 8/14/25.
//


private struct SRToggleButton: View {
    @Binding var isOff: Bool
    let buttonAction: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.bouncy(duration: 0.4)) {
                buttonAction()
            }
        }) {
            ZStack(alignment: isOff ? .leading : .trailing) {
                RoundedRectangle(cornerRadius: .infinity)
                    .fill(isOff ? Color.srLightGray : Color.main)
                    .frame(width: 55, height: 30)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                
                Circle()
                    .fill(isOff ? Color.clear : .splash)
                    .frame(width: 25, height: 25)
                    .padding(2.5)
            }
        }
        .buttonStyle(.plain)
    }
}
