//
//  CancelBag.swift
//  saerok
//
//  Created by HanSeung on 4/8/25.
//


import Combine

final class CancelBag {
    fileprivate(set) var subscriptions = Set<AnyCancellable>()
    private let equalToAny: Bool
    
    init(equalToAny: Bool = false) {
        self.equalToAny = equalToAny
    }
 
    func cancel() {
        subscriptions.removeAll()
    }
    
    func isEqual(to other: CancelBag) -> Bool {
        return other === self || other.equalToAny || self.equalToAny
    }
    
    func collect(@Builder _ cancellables: () -> [AnyCancellable]) {
        subscriptions.formUnion(cancellables())
    }
}

extension CancelBag {
    @resultBuilder
    struct Builder {
        static func buildBlock(_ cancellables: AnyCancellable...) -> [AnyCancellable] {
            cancellables
        }
    }
}

extension AnyCancellable {
    func store(in cancelBag: CancelBag) {
        cancelBag.subscriptions.insert(self)
    }
}

extension Task {
    func store(in cancelBag: CancelBag) {
        AnyCancellable {
            self.cancel()
        }
        .store(in: cancelBag)
    }
}
