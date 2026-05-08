//
//  S3Uploader.swift
//  saerok
//
//  Created by HanSeung on 6/7/25.
//


import Foundation

struct S3Uploader {
    static func uploadImage(to urlString: String, data: Data) async throws {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.httpBody = data

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}
