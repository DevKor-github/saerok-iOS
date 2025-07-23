//
//  CollectionShareView.swift
//  saerok
//
//  Created by HanSeung on 6/10/25.
//

import SwiftUI

struct CollectionShareView: View {
    let collection: Local.CollectionDetail
    @Binding var isPresented: Bool
    var image: UIImage
    let customImageView: CollectionCustomView
    let snapshot: UIImage

    init(collection: Local.CollectionDetail, isPresented: Binding<Bool>, image: UIImage) {
        self.collection = collection
        self._isPresented = isPresented
        self.image = image
        self.customImageView = CollectionCustomView(collection: collection, downloadedImage: image)
        self.snapshot = customImageView.snapshot(size: CGSize(width: 343, height: 471))
    }

    var body: some View {
        ZStack {
            backgroundColor
                .onTapGesture { isPresented.toggle() }

            VStack(spacing: 12) {
                headerSection
                customImageView
                shareButtonSection
                Spacer()
            }
            .padding()
        }
    }

    private var backgroundColor: some View {
        Color.black.opacity(0.6)
            .ignoresSafeArea()
    }

    private var headerSection: some View {
        HStack {
            Text("내 새록을 공유해보세요!")
                .font(.SRFontSet.headline2)
                .foregroundColor(.srWhite)
            Spacer()
            Button {
                isPresented.toggle()
            } label: {
                Image.SRIconSet.delete
                    .frame(.defaultIconSize)
                    .foregroundColor(.black)
            }
            .buttonStyle(.icon)
        }
        .padding(.horizontal)
        .padding(.top)
    }

    private var shareButtonSection: some View {
        HStack {
            Spacer()
            VStack(alignment: .trailing, spacing: 8) {
                ForEach(ShareType.allCases, id: \.self) { type in
                    if type == .export {
                        ShareLink(
                            item: Image(uiImage: snapshot),
                            preview: SharePreview("'\(self.collection.birdName ?? "이름 모를 새")'를 공유", image: Image(uiImage: image))
                        ) {
                            shareButton(type, action: {})
                        }
                    } else {
                        shareButton(type, action: {
                            handleShareAction(for: type)
                        })
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

private extension CollectionShareView {
    enum ShareType: CaseIterable {
        case export
        case instagram
        case imageSave

        var title: String {
            switch self {
            case .instagram: "인스타그램으로 공유하기"
            case .imageSave: "이미지 저장하기"
            case .export: "공유하기"
            }
        }

        var image: Image.SRIconSet {
            switch self {
            case .instagram: .insta
            case .imageSave: .download
            case .export: .share
            }
        }
    }

    func shareButton(_ type: ShareType, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                type.image
                    .frame(.defaultIconSize)
                    .foregroundStyle(.accent)
                Text(type.title)
                    .font(.SRFontSet.button2)
                    .foregroundStyle(.black)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 9)
            .background(Color.srWhite)
            .cornerRadius(.infinity)
        }
        .disabled(type == .export)
    }

    func handleShareAction(for type: ShareType) {
        switch type {
        case .export:
            print("공유하기")
        case .instagram:
            shareToInstagram(background: self.snapshot, sticker: snapshot)
        case .imageSave:
            UIImageWriteToSavedPhotosAlbum(self.snapshot, nil, nil, nil)
        }
    }

    func isInstagramInstalled() -> Bool {
        guard let instagramURL = URL(string: "instagram-stories://share") else {
            return false
        }
        return UIApplication.shared.canOpenURL(instagramURL)
    }

    func shareToInstagram(background: UIImage?, sticker: UIImage?) {
        guard let background,
              let sticker,
              let backgroundData = background.pngData(),
              let stickerData = sticker.pngData() else { return }

        shareToInstagram(backgroundImage: backgroundData, stickerImage: stickerData, appID: "1175065814361224")
    }

    func shareToInstagram(backgroundImage: Data, stickerImage: Data, appID: String) {
        guard let instagramURL = URL(string: "instagram-stories://share?source_application=" + appID) else { return }
        guard isInstagramInstalled() else { return }

        let pasteboardItems = [[
            "com.instagram.sharedSticker.stickerImage": stickerImage,
            "com.instagram.sharedSticker.backgroundTopColor" : "#F2F2F2",
            "com.instagram.sharedSticker.backgroundBottomColor" : "#CDDDF3",
        ]]

        let pasteboardOptions: [UIPasteboard.OptionsKey: Any] = [
            .expirationDate: Date(timeIntervalSinceNow: 60 * 5)
        ]

        UIPasteboard.general.setItems(pasteboardItems, options: pasteboardOptions)
        UIApplication.shared.open(instagramURL, options: [:])
    }
}
