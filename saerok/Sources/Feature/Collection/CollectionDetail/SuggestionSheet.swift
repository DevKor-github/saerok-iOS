//
//  SuggestionSheet.swift
//  saerok
//
//  Created by HanSeung on 7/31/25.
//


import SwiftUI
import SwiftData

struct SuggestionSheet: View {
    let isFromMap: Bool
    let collectionID: Int
    let nickname: String
    @Binding var suggestions: [Local.BirdSuggestion]
    @Binding var selectedBird: Local.Bird?
    @Binding var selectedPreview: Local.BirdSuggestion?
    @Binding var selectedAdopting: Local.BirdSuggestion?
    
    @Binding var showSuggestPopup: Bool
    @Binding var showAdoptPopup: Bool

    let onDismiss: () -> Void
    let onFindBird: () -> Void
    
    @Environment(\.injected) private var injected: DIContainer
    private var interactor: CollectionInteractor { injected.interactors.collection }
    
    var body: some View {
        VStack(spacing: 20) {
            header
            
            if suggestions.isEmpty && !isFromMap {
                emptyView
            } else {
                content
            }
        }
        .onChange(of: selectedBird) { _, newValue in
            guard let _ = newValue else { return }
            showSuggestPopup = true
        }
        .onChange(of: suggestions) { _, _ in
            sortSuggestions()
        }
    }
}

// MARK: - Subviews

private extension SuggestionSheet {
    var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("이 새 같아요!")
                Spacer()
                Button(action: onDismiss) {
                    Image.SRIconSet.delete
                        .frame(.defaultIconSizeSmall, tintColor: .srGray)
                }
            }
            .font(.SRFontSet.subtitle2)
            
            Text(
                isFromMap
                 ? "\(nickname)님에게 새의 이름을 알려주세요."
                 : "다른 사용자들이 이 새의 이름을 알려주고 있어요."
            )
                .font(.SRFontSet.body2)
                .foregroundStyle(.srGray)
        }
        .padding(.horizontal, SRDesignConstant.defaultPadding)
    }
    
    var content: some View {
        ScrollView {
            VStack(spacing: 7) {
                ForEach($suggestions) { item in
                    SuggestionCell(
                        item: item,
                        selectedId: selectedPreview?.bird.id,
                        isMine: !isFromMap,
                        onAgree: { toggle(.agree, suggestion: item) },
                        onDisagree: { toggle(.disagree, suggestion: item) },
                        onAdopt: {
                            showAdoptPopup = true
                            selectedAdopting = item.wrappedValue
                        },
                        onTap: { selectedPreview = item.wrappedValue },
                    )
                }
                
                if isFromMap {
                    defaultAddCell
                }
                
                Color.clear
                    .frame(height: UIScreen.main.bounds.height * 0.5)
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }
    
    private var emptyView: some View {
        VStack(spacing: 32) {
            VStack(spacing: 5) {
                Text("아직 새 이름을 아는 친구가 없네요.")
                    .font(.SRFontSet.subtitle1_2)
                Text("누군가 이름 후보를 등록하면 알림으로 알려드릴게요.")
                    .font(.SRFontSet.body2)
                    .foregroundStyle(Color.srDarkGray)
            }
            Image(.logoBack)
                .renderingMode(.template)
                .resizable()
                .foregroundStyle(.srWhite)
                .frame(width: 116, height: 128)
        }
        .padding(.top, 78)
    }
    
    var defaultAddCell: some View {
        HStack {
            Button(action: onFindBird) {
                HStack {
                    Text("후보 추가하기")
                        .font(.SRFontSet.button2)
                        .foregroundStyle(.splash)
                        .padding(19)
                    
                    Spacer()
                    
                    Image.SRIconSet.plus
                        .frame(.defaultIconSize)
                        .padding(8)
                        .background(
                            Circle().fill(.glassWhite)
                                .frame(width: 40, height: 40)
                        )
                        .frame(width: 40, height: 40)
                        .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 0)
                        .padding(11)
                }
            }
            .background(Color.srWhite)
            .cornerRadius(20)
            .padding(.horizontal, SRDesignConstant.defaultPadding)
        }
    }
}

// MARK: - Networking

private extension SuggestionSheet {
    enum SuggestionAction {
        case agree
        case disagree
    }
    
    func toggle(_ action: SuggestionAction, suggestion: Binding<Local.BirdSuggestion>) {
        Task {
            HapticManager.shared.trigger(.light)
            let result: Local.BirdSuggestion
            switch action {
            case .agree:
                result = try await interactor.toggleAgree(collectionID, suggestion: suggestion.wrappedValue)
            case .disagree:
                result = try await interactor.toggleDisagree(collectionID, suggestion: suggestion.wrappedValue)
            }
            
            suggestion.wrappedValue = result
        }
    }
    
    func sortSuggestions() {
        suggestions.sort {
            if $0.agreeCount == $1.agreeCount {
                return $0.disagreeCount < $1.disagreeCount
            }
            return $0.agreeCount > $1.agreeCount
        }
    }
}
