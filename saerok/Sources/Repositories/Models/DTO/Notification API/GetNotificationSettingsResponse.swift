extension DTO {
    struct GetNotificationSettingsResponse: Decodable {
        let deviceId: String
        let LIKE: Bool
        let COMMENT: Bool
        let BIRD_ID_SUGGESTION: Bool
        let SYSTEM: Bool
    }
}