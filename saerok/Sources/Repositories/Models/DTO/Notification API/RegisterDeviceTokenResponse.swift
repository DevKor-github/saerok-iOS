struct RegisterDeviceTokenResponse: Decodable {
    let deviceId: String
    let success: Bool
}