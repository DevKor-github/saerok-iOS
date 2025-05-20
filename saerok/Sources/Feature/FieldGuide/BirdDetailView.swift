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
    
    private let bird: Local.Bird
    @Binding var path: NavigationPath
    
    init(_ bird: Local.Bird, path: Binding<NavigationPath>) {
        self.bird = bird
        self._path = path
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.mainSpacing) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Constants.scrollContentSpacing) {
                    birdImageWithTag
                    Group {
                        title
                        classification
                        description
                    }
                    .padding(.horizontal, SRDesignConstant.defaultPadding)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .regainSwipeBack()
    }
}

// MARK: - UI Components

private extension BirdDetailView {
    var birdImageWithTag: some View {
        VStack(alignment: .leading, spacing: Constants.birdImageSpacing) {
            if let url = bird.imageURL {
                ZStack(alignment: .bottomTrailing) {
                    ReactiveAsyncImage(url: url, scale: .large, quality: 1, downsampling: false)
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(Constants.imageCornerRadius)
                        .padding(.horizontal, SRDesignConstant.defaultPadding)
                        
                    topLeadingButton
                    bottomTrailingButtons
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
    
    var topLeadingButton: some View {
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
    
    var bottomTrailingButtons: some View {
        HStack(spacing: 7) {
            Button(action: bookmarkButtonTapped) {
                Group {
                    (bird.isBookmarked
                     ? Image.SRIconSet.bookmarkFilled
                     : Image.SRIconSet.bookmark)
                    .frame(.defaultIconSizeLarge)
                }
                .foregroundStyle(bird.isBookmarked ? Color.main : Color.black)
            }
            
            Button(action: saerokButtonTapped) {
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
    
    var title: some View {
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
    
    var classification: some View {
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
    
    var description: some View {
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
}

private extension BirdDetailView {
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
    
    func bookmarkButtonTapped() {
        bird.isBookmarked.toggle()
    }
    
    func saerokButtonTapped() {
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
    
    BirdDetailView(.mockData[0], path: $path)
}
