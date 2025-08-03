import SwiftUI

struct NotificationCell: View {
    let item: NotificationItem

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ReactiveAsyncImage(
                url: item.imageUrl,
                scale: .medium,
                quality: 0.8,
                downsampling: true
            )
            .frame(width: 25, height: 25)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .inset(by: 0.8)
                    .stroke(.srLightGray, lineWidth: 2)
            )
            .padding(.leading, 9)
            .padding(.trailing, 6)

            VStack(alignment: .leading, spacing: 3) {
                notificationText
                    .font(.SRFontSet.body4)
                    .foregroundStyle(item.isRead ? .srGray : .black)
                
                Text(item.createdAt.timeAgoText)
                    .font(.SRFontSet.caption3)
                    .foregroundStyle(.srGray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            ReactiveAsyncImage(
                url: item.imageUrl,
                scale: .medium,
                quality: 0.8,
                downsampling: true
            )
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: 60, maxHeight: 60)
            .clipped()
            .cornerRadius(12)
        }
        .padding(10)
        .frame(height: 78)
        .background(Color.srWhite)
        .cornerRadius(20)
        .overlay(
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 20)
                    .inset(by: 0.4)
                    .stroke(Color.srLightGray, lineWidth: 1)
                
                Circle()
                    .fill(item.isRead ? .clear : Color.splash)
                    .frame(width: 5, height: 5)
                    .offset(x: 9, y: 19)
            }
        )
    }

    @ViewBuilder
    private var notificationText: some View {
        switch item.type {
        case .like:
            Text(item.nickname).bold() + Text("님이 나의 새록을 좋아해요.")
        case .comment:
            Text(item.nickname).bold() + Text("님이 나의 새록에 댓글을 남겼어요. ") + Text("“\(item.content)”").italic()
        case .birdIdSuggestion:
            Text("두근두근! 새로운 의견이 공유됐어요. 확인해볼까요?")
        case .system:
            Text(item.content)
        }
    }
}