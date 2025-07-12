import SwiftUI

struct CollectionCustomView: View {
    let collection: Local.CollectionDetail
    let downloadedImage: UIImage

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(uiImage: downloadedImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: Layout.imageMaxWidth)
                .frame(height: Layout.imageHeight)
                .clipped()
                .cornerRadius(10)
                .padding(Layout.imagePadding)

            collectionInfoSection

            Spacer()

            bottomIconSection
        }
        .frame(width: Layout.viewWidth, height: Layout.viewHeight)
        .background(Color.srWhite)
        .cornerRadius(20)
    }

    private var collectionInfoSection: some View {
        HStack {
            Text(collection.birdName ?? "이름 모를 새")
                .font(.SRFontSet.headline2_2)
            Spacer()
            VStack(alignment: .trailing) {
                Text(collection.discoveredDate.toEnglishLongString())
                Text(collection.locationAlias)
            }
            .font(.SRFontSet.caption1)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, Layout.infoSectionHorizontalPadding)
    }

    private var bottomIconSection: some View {
        HStack {
            Spacer()
            Image(.vector)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Layout.iconSize)
                .padding(Layout.iconPadding)
        }
    }
}

private enum Layout {
    static let viewWidth: CGFloat = 343
    static let viewHeight: CGFloat = 471
    static let imageMaxWidth: CGFloat = 322.9
    static let imageHeight: CGFloat = 350
    static let imagePadding: CGFloat = 10
    static let infoSectionHorizontalPadding: CGFloat = 15
    static let iconSize: CGFloat = 30
    static let iconPadding: CGFloat = 15
}
