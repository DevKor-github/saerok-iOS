//
//  SRNetworkService.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//

final class SRNetworkService: DefaultNetworkService {
    func fetch(endpoint: Endpoint) {
        let request = endpoint.createRequest()
    }
}
