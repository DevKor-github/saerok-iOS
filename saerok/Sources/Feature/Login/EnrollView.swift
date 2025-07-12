//
//  EnrollView.swift
//  saerok
//
//  Created by HanSeung on 5/18/25.
//


import SwiftUI
import SwiftData

struct EnrollView: View {
    @Environment(\.injected) private var injected: DIContainer
    @Environment(\.modelContext) var context

    @Binding var user: User

    init(user: Binding<User>) {
        self._user = user
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            navigationBar
            Group {
                headerSection
                Rectangle().fill(.clear)
                    .frame(height: 40)
                formSection
            }
            .padding(.horizontal, SRDesignConstant.defaultPadding)
            Spacer()
        }
        .padding(.vertical, 43)
        .regainSwipeBack()
    }
    
    // MARK: - Subviews
    
    private var navigationBar: some View {
        NavigationBar(leading: {
            Button(action: handleBackButton) {
                Image.SRIconSet.chevronLeft
                    .frame(.defaultIconSize)
            }
        })
    }

    private var headerSection: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 5) {
                Text("회원가입")
                    .font(.SRFontSet.headline1)
                Text("닉네임만 입력하면 회원가입이 끝나요!")
                    .font(.SRFontSet.body2)
                    .foregroundStyle(.secondary)
            }
            
            ZStack {
                dashedLine
//                stepIndicators
            }
            .frame(height: 38)
        }
    }

    private var dashedLine: some View {
        Canvas { context, size in
            var path = Path()
            path.move(to: .zero)
            path.addLine(to: CGPoint(x: size.width, y: 0))
            context.stroke(
                path,
                with: .color(.srGray),
                style: StrokeStyle(lineWidth: 1, dash: [2, 2])
            )
        }
        .frame(height: 1)
    }

//    private var stepIndicators: some View {
//        HStack(spacing: 34) {
//            Spacer()
//            ForEach(Step.allCases, id: \.rawValue) { step in
//                Text("\(step.rawValue + 1)")
//                    .font(.SRFontSet.subtitle3)
//                    .bold()
//                    .foregroundStyle(.srWhite)
//                    .background(
//                        Circle()
//                            .frame(width: Constants.stepCircleSize, height: Constants.stepCircleSize)
//                            .foregroundStyle(currentStep == step ? .main : .whiteGray)
//                    )
//                    .frame(width: Constants.stepCircleSize, height: Constants.stepCircleSize)
//            }
//        }
//    }
    
    private var formSection: some View {
        EnrollFirstFormView(user: $user)
    }
    
    // MARK: - Button Actions
    
    private func handleBackButton() {
        injected.appState[\.authStatus] = .notDetermined
    }
}

// MARK: - Constants

extension EnrollView {
    enum Constants {
        static let imageSize: CGFloat = 100
        static let imageCornerRadius: CGFloat = 10
        static let formHeight: CGFloat = 44
        static let maxNoteLength: Int = 100
        static let deleteButtonOffset: CGFloat = imageSize / 2
        static let stepCircleSize: CGFloat = 38
    }
}

#Preview {
    @Previewable @State var user: User = .init()
    
    EnrollView(user: $user)
}
