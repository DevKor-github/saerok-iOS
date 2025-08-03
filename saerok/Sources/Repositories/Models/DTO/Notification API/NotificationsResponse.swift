extension DTO {
    struct NotificationsResponse: Decodable {
        struct Item: Decodable {
            let commentId: Int
            let userId: Int
            let nickname: String
            let profileImageUrl: String?
            let content: String
            let likeCount: Int
            let isLiked: Bool
            let isMine: Bool
            let createdAt: String
            let updatedAt: String
        }
        let items: [Item]
    }
}