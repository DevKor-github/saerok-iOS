//
//  CancelBag.swift
//  saerok
//
//  Created by HanSeung on 4/8/25.
//


import Combine

final class CancleBag {
    fileprivate(set) var cancellables = [any Cancellable]()
    private let equalToAny: Bool
    
    init(equalToAny: Bool = false) {
        self.equalToAny = equalToAny
    }
    
    func cancel() {
        cancellables.removeAll()
    }
    
    func isEqual(to other: CancleBag) -> Bool {
        return other === self || other.equalToAny || self.equalToAny
    }
}

extension Cancellable {
    func store(in cancelBag: CancleBag) {
        cancelBag.cancellables.append(self)
    }
}

extension Task: @retroactive Cancellable { }
