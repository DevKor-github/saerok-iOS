//
//  SRNetworkService.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//

final class SRNetworkService: DefaultNetworkService {
    func fetchBirdList(endpoint: SREndpoint) async throws -> [DTO.Bird] {
        let request = endpoint.createRequest()
        let response: DTO.BirdsResponse = try await provider.request(request)
        return response.birds
    }
}
