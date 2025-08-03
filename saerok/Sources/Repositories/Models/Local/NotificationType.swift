extension Local {
    enum NotificationType: String, Codable, CaseIterable {
        case like = "LIKE"
        case comment = "COMMENT"
        case birdIdSuggestion = "BIRD_ID_SUGGESTION"
        case system = "SYSTEM"
    }
}