//
//  SourceSheet.swift
//  saerok
//
//  Created by HanSeung on 3/9/26.
//

import SwiftUI

struct SourceSheet: View {
    let nextButtonTapped: () async throws -> Void
    @State var enrollStatus: EnrollStatus = .editing
    @State private var showError: Bool = false
    @Binding var singupSource: SignUpSource?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header
                .padding(.top, 97)
            Spacer()
            sourcesGrid
            completeButton
        }
        .padding(.horizontal, 25)
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 4.75) {
            Text("어디서 보고 오셨나요?")
                .font(.SRFontSet.headline1)
            Text("마지막 단계예요!")
                .font(.SRFontSet.body2)
                .foregroundStyle(.srGray)
        }
    }
    
    private var sourcesGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]
        
        return LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
            ForEach(SignUpSource.allCases, id: \.self) { source in
                Button { singupSource = source } label: {
                    let isChecked = singupSource == source
                    VStack(alignment: .leading) {
                        HStack(alignment: .top) {
                            Text(source.title)
                                .font(.SRFontSet.body1)
                                .foregroundStyle(isChecked ? Color.srWhite : Color.primary)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            isChecked
                            ? Image.SRIconSet.checkboxMiniCheckedReverse
                                .frame(.defaultIconSize)
                            : Image.SRIconSet.checkboxMiniDefault
                                .frame(.defaultIconSize)
                        }
                        Spacer()
                    }
                    .padding(15)
                    .frame(maxWidth: .infinity)
                    .frame(height: 123)
                    .background(isChecked ? Color.accent : Color.srLightGray)
                    .cornerRadius(10)
                }
            }
        }
    }
    
    private var completeButton: some View {
        VStack(spacing: 12) {
            if showError {
                Text("오류가 발생했어요. 다시 시도해주세요.")
                    .font(.SRFontSet.caption1)
                    .foregroundStyle(.red)
            }
            Button {
                Task {
                    showError = false
                    enrollStatus = .loading
                    do {
                        try await nextButtonTapped()
                    } catch {
                        enrollStatus = .editing
                        showError = true
                    }
                }
            } label: {
                if enrollStatus == .loading {
                    ProgressView()
                } else {
                    Text("완료")
                }
            }
            .srStyled(.primaryButton)
            .disabled(singupSource == nil || enrollStatus == .loading)
        }
    }
}
