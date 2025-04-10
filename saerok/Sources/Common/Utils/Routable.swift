//
//  Routable.swift
//  saerok
//
//  Created by HanSeung on 4/9/25.
//


import Combine
import SwiftUI

protocol Routable: View {
    associatedtype Routing: Equatable
    var routingState: Routing { get set }
    var routingBinding: Binding<Routing> { get }
    var routingUpdate: AnyPublisher<Routing, Never> { get }
}

extension Routable {
    var routingBinding: Binding<Routing> {
        fatalError("Must override routingBinding in your View")
    }

    var routingUpdate: AnyPublisher<Routing, Never> {
        Empty().eraseToAnyPublisher()
    }
}
