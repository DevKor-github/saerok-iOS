//
//  EnrollView.swift
//  saerok
//
//  Created by HanSeung on 5/18/25.
//


import SwiftUI
import SwiftData

struct EnrollView: View {
    enum Step: Int, CaseIterable {
        case first = 0
        case second
    }

    @Environment(\.injected) private var injected: DIContainer
    @Environment(\.modelContext) var context

    @Binding var user: User
    @Binding var path: NavigationPath

    @State private var currentStep: Step = .first

    init(path: Binding<NavigationPath>, user: Binding<User>) {
        self._path = path
        self._user = user
    }

    var body: some View {
        VStack(alignment: .leading) {
            navigationBar
            headerSection
            formSection
            Spacer()
        }
        .padding(.horizontal, SRDesignConstant.defaultPadding)
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
        VStack(alignment: .leading, spacing: 12) {
            Text("회원가입")
                .font(.SRFontSet.headline1)

            ZStack {
                dashedLine
                stepIndicators
            }
            .frame(height: 38)
            .padding(.bottom, 54)
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

    private var stepIndicators: some View {
        HStack(spacing: 34) {
            Spacer()
            ForEach(Step.allCases, id: \.rawValue) { step in
                Text("\(step.rawValue + 1)")
                    .font(.SRFontSet.subtitle3)
                    .bold()
                    .foregroundStyle(.srWhite)
                    .background(
                        Circle()
                            .frame(width: Constants.stepCircleSize, height: Constants.stepCircleSize)
                            .foregroundStyle(currentStep == step ? .main : .whiteGray)
                    )
                    .frame(width: Constants.stepCircleSize, height: Constants.stepCircleSize)
            }
        }
    }

    private var formSection: some View {
        NonSwipeablePageTabView(
            currentPage: Binding(
                get: { currentStep.rawValue },
                set: { currentStep = Step(rawValue: $0) ?? .first }
            ),
            pages: [
                AnyView(EnrollFirstFormView(currentStep: $currentStep, user: $user)),
                AnyView(EnrollSecondFormView(currentStep: $currentStep, user: $user))
            ]
        )
    }

    // MARK: - Button Actions

    private func handleBackButton() {
        if currentStep == .first {
            path.removeLast()
        } else {
            currentStep = .first
        }
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
