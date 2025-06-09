//
//  BirdDetailView.swift
//  saerok
//
//  Created by HanSeung on 4/12/25.
//

import Combine
import SwiftUI

struct BirdDetailView: View {
    @Environment(\.injected) var injected
    @Environment(\.modelContext) private var modelContext

    @State private var birdID: Int? = nil
    @State private var bird: Local.Bird? = nil
    @Binding var path: NavigationPath
    
    // MARK: - 초기화: birdID로 받는 경우
    
    init(birdID: Int, path: Binding<NavigationPath>) {
        self._path = path
        self._birdID = State(initialValue: birdID)
        self._bird = State(initialValue: nil)
    }
    
    // MARK: - 초기화: Local.Bird로 받는 경우
    
    init(bird: Local.Bird, path: Binding<NavigationPath>) {
        self._path = path
        self._bird = State(initialValue: bird)
        self._birdID = State(initialValue: nil)
    }
    
    var body: some View {
        Group {
            if let bird = bird {
                contentView(bird: bird)
            } else {
                ProgressView("로딩 중...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear {
                        loadBirdIfNeeded()
                    }
            }
        }
        .regainSwipeBack()
    }
    
    // MARK: - 본문 뷰
    @ViewBuilder
    private func contentView(bird: Local.Bird) -> some View {
        VStack(alignment: .leading, spacing: Constants.mainSpacing) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Constants.scrollContentSpacing) {
                    birdImageWithTag(bird: bird)
                    Group {
                        title(bird: bird)
                        classification(bird: bird)
                        description(bird: bird)
                    }
                    .padding(.horizontal, SRDesignConstant.defaultPadding)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - 데이터 로딩

private extension BirdDetailView {
    func loadBirdIfNeeded() {
        guard bird == nil, let birdID = birdID else { return }
        
        Task { @MainActor in
            if let foundBird = try? await injected.interactors.fieldGuide.loadBirdDetails(birdID: birdID) {
                self.bird = foundBird
            }
        }
    }
}

// MARK: - UI Components

private extension BirdDetailView {
    func birdImageWithTag(bird: Local.Bird) -> some View {
        VStack(alignment: .leading, spacing: Constants.birdImageSpacing) {
            if let url = bird.imageURL {
                ZStack(alignment: .bottomTrailing) {
                    ReactiveAsyncImage(url: url, scale: .large, quality: 1, downsampling: false)
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(Constants.imageCornerRadius)
                        .padding(.horizontal, SRDesignConstant.defaultPadding)
                    
                    topLeadingButton()
                    bottomTrailingButtons(bird: bird)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Constants.chipSpacing) {
                    Color.clear.frame(width: Constants.chipSidePadding)
                    ChipList(icon: .seasonWhite, list: bird.seasons)
                    ChipList(icon: .habitatWhite, list: bird.habitats)
                    ChipList(icon: .sizeWhite, list: [bird.size])
                    Color.clear.frame(width: Constants.chipSidePadding)
                }
            }
        }
    }
    
    func topLeadingButton() -> some View {
        VStack {
            HStack {
                Button(action: backButtonTapped) {
                    Image.SRIconSet.chevronLeft
                        .frame(.defaultIconSize)
                }
                .srStyled(.iconButton)
                Spacer()
            }
            Spacer()
        }
        .padding(8)
        .padding(.leading, SRDesignConstant.defaultPadding)
    }
    
    func bottomTrailingButtons(bird: Local.Bird) -> some View {
        HStack(spacing: 7) {
            Button(action: {
                bookmarkButtonTapped(bird: bird)
            }) {
                Group {
                    (bird.isBookmarked
                     ? Image.SRIconSet.bookmarkFilled
                     : Image.SRIconSet.bookmark)
                    .frame(.defaultIconSizeLarge)
                }
                .foregroundStyle(bird.isBookmarked ? Color.main : Color.black)
            }
            
            Button(action: { saerokButtonTapped(bird: bird) }) {
                Image.SRIconSet.penFill
                    .frame(.custom(width: Constants.penIconWidth, height: Constants.penIconHeight))
                    .padding(.top, Constants.penIconTopPadding)
            }
            .frame(alignment: .bottomTrailing)
        }
        .srStyled(.iconButton)
        .padding(8)
        .padding(.trailing, SRDesignConstant.defaultPadding)
    }
    
    func title(bird: Local.Bird) -> some View {
        VStack(alignment: .center) {
            Text(bird.name)
                .font(.SRFontSet.subtitle1)
            Text(bird.scientificName)
                .font(.SRFontSet.body2)
                .foregroundStyle(.srGray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .padding(.top, 20)
    }
    
    func classification(bird: Local.Bird) -> some View {
        VStack(alignment: .leading, spacing: Constants.sectionSpacing) {
            Text("분류")
                .font(.SRFontSet.subtitle2)
                .bold()
            Text(bird.classification)
                .font(.SRFontSet.caption1)
                .foregroundStyle(.secondary)
                .lineSpacing(Constants.lineSpacing)
        }
    }
    
    func description(bird: Local.Bird) -> some View {
        VStack(alignment: .leading, spacing: Constants.sectionSpacing) {
            Text("상세 설명")
                .font(.SRFontSet.subtitle2)
                .bold()
            Text(bird.detail)
                .allowsTightening(true)
                .font(.SRFontSet.body2)
                .lineSpacing(Constants.lineSpacing)
            
            Color.clear.frame(height: Constants.bottomSpacerHeight)
        }
    }
    
    struct ChipList<T: Hashable & RawRepresentable & CaseIterable>: View where T.RawValue == String {
        let icon: Image.SRIconSet
        let list: [T]
        
        var body: some View {
            HStack {
                icon.frame(.defaultIconSizeSmall)
                
                if list.isEmpty {
                    Text("미등록")
                } else {
                    Text(list.map(\.rawValue).joined(separator: " • "))
                }
            }
            .font(.SRFontSet.body1)
            .bold()
            .padding(.horizontal, Constants.chipHorizontalPadding)
            .padding(.vertical, Constants.chipVerticalPadding)
            .foregroundStyle(.srWhite)
            .background(Color.main)
            .cornerRadius(.infinity)
        }
    }
}

// MARK: - Button Actions

private extension BirdDetailView {
    func backButtonTapped() {
        path.removeLast()
    }
    
    func bookmarkButtonTapped(bird: Local.Bird) {
        Task {
            HapticManager.shared.trigger(.light)
            self.bird?.isBookmarked = try await injected.interactors.fieldGuide.toggleBookmark(birdID: bird.id)
            HapticManager.shared.trigger(.success)
        }
    }
    
    func saerokButtonTapped(bird: Local.Bird) {
        injected.appState[\.routing.contentView.tabSelection] = .collection
        injected.appState[\.routing.collectionView.addCollection] = true
        injected.appState[\.routing.addCollectionItemView.selectedBird] = bird
    }
}

// MARK: - Constants

private extension BirdDetailView {
    enum Constants {
        static let mainSpacing: CGFloat = 11
        static let scrollContentSpacing: CGFloat = 30
        static let birdImageSpacing: CGFloat = 13
        static let chipSpacing: CGFloat = 5
        static let chipSidePadding: CGFloat = 20
        static let imageCornerRadius: CGFloat = 20
        static let sectionSpacing: CGFloat = 13
        static let lineSpacing: CGFloat = 5
        static let bottomSpacerHeight: CGFloat = 80
        static let navLeadingSpacing: CGFloat = 18
        static let navTrailingSpacing: CGFloat = 25
        static let penIconWidth: CGFloat = 26
        static let penIconHeight: CGFloat = 26
        static let penIconTopPadding: CGFloat = 3
        
        // ChipList
        static let chipHorizontalPadding: CGFloat = 13
        static let chipVerticalPadding: CGFloat = 7
    }
}

#Preview {
    @Previewable @State var path: NavigationPath = .init()
    
    BirdDetailView(bird: .mockData[0], path: $path)
}
