//
//  TermsAgreementSheet.swift
//  saerok
//
//  Created by HanSeung on 11/3/25.
//

import SwiftUI

struct TermsAgreementSheet: View {
    let onDismiss: () -> Void
    let nextButtonTapped: () -> Void

    @State private var agreements: [TermsAgreementType: Bool] = {
        var dict: [TermsAgreementType: Bool] = [:]
        TermsAgreementType.allCases.forEach { dict[$0] = false }
        return dict
    }()
    @State private var isAllAgreed = false
    @Binding var enrollStatus: EnrollStatus

    var body: some View {
        content
            .onChange(of: agreements) { _, dict in
                let newAll = TermsAgreementType.allCases.allSatisfy { dict[$0] ?? false }
                if newAll != isAllAgreed { isAllAgreed = newAll }
            }
            .onChange(of: isAllAgreed) { _, newValue in
                TermsAgreementType.allCases.forEach { agreements[$0] = newValue }
            }
    }
}

// MARK: - Subviews
private extension TermsAgreementSheet {
    var content: some View {
        VStack(alignment: .center, spacing: 0) {
            terms
                
            Spacer()
            
            Button(action: nextButtonTapped) {
                if enrollStatus == .loading {
                    ProgressView()
                } else {
                    Text("다음")
                }
            }
            .srStyled(.primaryButton)
            .disabled(!isAllAgreed || enrollStatus == .loading)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .srbottomSheetStyle(presentationDetent: [.fraction(0.55)], backgroundColor: .srWhite)
    }
    
    var header: some View {
        HStack {
            Text("약관 동의가 필요해요.")
                .font(.SRFontSet.subtitle1_3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 7)
            Spacer()
            Button(action: { onDismiss() }) {
                Image.SRIconSet.delete
                    .frame(.defaultIconSizeSmall, tintColor: .srGray)
            }
            .contentShape(Rectangle())
        }
        .background(.srWhite)
    }
    
    @ViewBuilder
    var terms: some View {
        header
        starredText("표시는 필수 항목이에요.", color: .srGray)
            .padding(.bottom, 28)
        
        textWithCheckBox(
            Text("필수 항목 전체 동의하기")
                .font(.SRFontSet.body0)
                .bold(),
            isChecked: $isAllAgreed
        )
        .padding(.bottom, 15)

        divider
            .padding(.bottom, 17)

        VStack(alignment: .leading, spacing: 14) {
            ForEach(TermsAgreementType.allCases) { item in
                textWithCheckBox(
                    starredText(item.title, associated: item.link),
                    isChecked: Binding(
                        get: { agreements[item] ?? false },
                        set: { agreements[item] = $0 }
                    )
                )
            }
        }
    }
    
    var star: some View {
        Text("*")
            .font(.SRFontSet.body0)
            .foregroundStyle(.red)
    }
    
    var divider: some View {
        Divider()
            .foregroundStyle(.whiteGray)
            .frame(height: 1.0)
    }
    
    func starredText(_ text: String, associated: String? = nil, color: Color = .srDarkGray) -> some View {
        HStack(spacing: 2) {
            star
            Text(text)
                .font(.SRFontSet.body1)
                .foregroundStyle(color)
                .padding(.trailing, 12)
            if let link = associated {
                Image.SRIconSet.chevronRight
                    .frame(.custom(width: 9, height: 9))
                    .foregroundStyle(.srDarkGray)
                    .onTapGesture { openURL(link) }
            }
            Spacer()
        }
    }
    
    func textWithCheckBox(_ text: some View, isChecked: Binding<Bool>) -> some View {
        HStack {
            text
            Spacer()
            (isChecked.wrappedValue
             ? Image.SRIconSet.checkboxChecked
             : Image.SRIconSet.checkboxDefault)
            .frame(.defaultIconSizeLarge)
            .onTapGesture {
                isChecked.wrappedValue.toggle()
            }
        }
    }
    
    func openURL(_ link: String) {
        guard let url = URL(string: link) else { return }
        UIApplication.shared.open(url)
    }
}

private enum TermsAgreementType: CaseIterable, Identifiable {
    case over14
    case terms
    case privacy
    case location

    var id: Self { self }

    var title: String {
        switch self {
        case .over14: return "만 14세 이상 확인"
        case .terms: return "새록 이용 약관 동의"
        case .privacy: return "개인정보 수집 및 이용 동의"
        case .location: return "위치정보 이용 약관 동의"
        }
    }
    
    var link: String? {
        switch self {
        case .terms: "https://shine-guppy-3de.notion.site/29e7cea87e058098adffe574164bb447?pvs=74"
        case .privacy: "https://shine-guppy-3de.notion.site/29d7cea87e058088a7cde5f3fc6622ad?pvs=74"
        case .location: "https://shine-guppy-3de.notion.site/2a07cea87e0580a9b966c6268754f7b6"
        default: nil
        }
    }
}
