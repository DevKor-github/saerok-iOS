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
    @State private var showPopup: Bool = false
    @Binding var path: NavigationPath
    private var isGuest: Bool { injected.appState[\.authStatus] == .guest }

    
    // MARK: - 초기화: birdID로 받는 경우
    
    init(birdID: Int, path: Binding<NavigationPath>) {
        self._path = path
        self._bird = State(initialValue: nil)
        self._birdID = State(initialValue: birdID)
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
        .customPopup(isPresented: $showPopup) { alertView }
    }
    
    @ViewBuilder
    private func contentView(bird: Local.Bird) -> some View {
        ZStack(alignment: .top) {
            ScrollView(showsIndicators: false) {
                Color.clear
                    .frame(height: 20)
                VStack(alignment: .leading, spacing: 0) {
                    birdImageWithTag(bird: bird)
                    Group {
                        title(bird: bird)
                        classification(bird: bird)
                            .padding(.bottom, 7)
                        description(bird: bird)
                    }
                    .padding(.horizontal, 9)
                }
                .frame(maxWidth: .infinity)
            }
            
            topBar(bird: bird)
                .padding(.top, 40)
        }
        .background(Color.srLightGray)
    }
    
    var alertView: CustomPopup<BorderedButtonStyle, ConfirmButtonStyle, PrimaryButtonStyle> {
        CustomPopup(
            title: "로그인이 필요한 기능이에요",
            message: "로그인하고 더 많은 기능을 사용해보세요!",
            leading: .init(
                title: "취소",
                action: alertDismissTapped,
                style: .bordered
            ),
            trailing: .init(
                title: "로그인",
                action: alertConfirmTapped,
                style: .confirm
            ),
            center: nil
        )
    }
}

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
                ReactiveAsyncImage(url: url, scale: .large, quality: 1, downsampling: false)
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(Constants.imageCornerRadius)
                    .padding(.horizontal, 9)
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
    
    func topBar(bird: Local.Bird) -> some View {
        HStack(spacing: 7) {
            Button(action: backButtonTapped) {
                Image.SRIconSet.chevronLeft
                    .frame(.defaultIconSize)
            }
            
            Spacer()
            
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
                Image.SRIconSet.jongchuMini
                    .frame(.defaultIconSizeLarge)
                    .padding(.top, Constants.penIconTopPadding)
            }
        }
        .srStyled(.iconButton)
        .padding(.leading, SRDesignConstant.defaultPadding)
        .padding(.trailing, 16)
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
        .padding(.vertical, 40)
    }
    
    func classification(bird: Local.Bird) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("분류")
                .font(.SRFontSet.caption3)
                .foregroundStyle(.srGray)
            Text(bird.classification)
                .font(.SRFontSet.body2)
                .lineSpacing(Constants.lineSpacing)
        }
        .modifier(CardStyleModifier())
    }
    
    
    @ViewBuilder
    func description(bird: Local.Bird) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("상세 설명")
                .font(.SRFontSet.caption3)
                .foregroundStyle(.srGray)
            Text(bird.detail)
                .allowsTightening(true)
                .font(.SRFontSet.body2)
                .lineSpacing(Constants.lineSpacing)
        }
        .modifier(CardStyleModifier())
        
        Color.clear.frame(height: Constants.bottomSpacerHeight)
    }
    
    struct ChipList<T: Hashable & RawRepresentable & CaseIterable>: View where T.RawValue == String {
        let icon: Image.SRIconSet
        let list: [T]
        
        var body: some View {
            HStack {
                icon.frame(.defaultIconSizeLarge)
                
                if list.isEmpty {
                    Text("정보 없음")
                } else {
                    Text(list.map(\.rawValue).joined(separator: " • "))
                }
            }
            .font(.SRFontSet.button2)
            .padding(.leading, 12)
            .padding(.trailing, 15)
            .padding(.vertical, 9)
            .foregroundStyle(.srWhite)
            .background(Color.main)
            .cornerRadius(.infinity)
        }
    }
    
    struct CardStyleModifier: ViewModifier {
        func body(content: Content) -> some View {
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 14)
                .padding(.horizontal, 20)
                .background(Color.srWhite)
                .cornerRadius(20)
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
            if !isGuest {
                HapticManager.shared.trigger(.light)
                self.bird?.isBookmarked = try await injected.interactors.fieldGuide.toggleBookmark(birdID: bird.id)
                HapticManager.shared.trigger(.success)
            } else {
                HapticManager.shared.trigger(.error)
                showPopup.toggle()
            }
        }
    }
    
    func saerokButtonTapped(bird: Local.Bird) {
        if !isGuest {
            injected.appState[\.routing.contentView.tabSelection] = .collection
            injected.appState[\.routing.collectionView.addCollection] = true
            injected.appState[\.routing.addCollectionItemView.selectedBird] = bird
        } else {
            HapticManager.shared.trigger(.error)
            showPopup.toggle()
        }
    }
    
    func alertDismissTapped() {
        showPopup = false
    }
    
    func alertConfirmTapped() {
        showPopup = false
        injected.appState[\.authStatus] = .notDetermined
    }
}

// MARK: - Constants

private extension BirdDetailView {
    enum Constants {
        static let mainSpacing: CGFloat = 11
        static let birdImageSpacing: CGFloat = 13
        static let chipSpacing: CGFloat = 5
        static let chipSidePadding: CGFloat = 11
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
