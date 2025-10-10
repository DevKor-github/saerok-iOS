//
//  CancelBag.swift
//  saerok
//
//  Created by HanSeung on 4/8/25.
//


import Combine

final class CancelBag {
    fileprivate(set) var cancellables = [any Cancellable]()
    private let equalToAny: Bool
    
    init(equalToAny: Bool = false) {
        self.equalToAny = equalToAny
    }
    
    func cancel() {
        cancellables.removeAll()
    }
    
    func isEqual(to other: CancelBag) -> Bool {
        return other === self || other.equalToAny || self.equalToAny
    }
}

extension Cancellable {
    func store(in cancelBag: CancelBag) {
        cancelBag.cancellables.append(self)
    }
}

extension Task: @retroactive Cancellable { }
