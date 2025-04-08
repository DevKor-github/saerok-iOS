//
//  Store.swift
//  saerok
//
//  Created by HanSeung on 4/8/25.
//


import SwiftUI
import Combine

typealias Store<State> = CurrentValueSubject<State, Never>

extension Store {
    subscript<T: Equatable>(keyPath: WritableKeyPath<Output, T>) -> T {
        get { value[keyPath: keyPath] }
        set {
            if value[keyPath: keyPath] != newValue {
                value[keyPath: keyPath] = newValue
                self.value = value
            }
        }
    }

    func bulkUpdate(_ update: (inout Output) -> Void) {
        var newValue = value
        update(&newValue)
        value = newValue
    }

    func updates<T: Equatable>(for keyPath: KeyPath<Output, T>) -> AnyPublisher<T, Failure> {
        map(keyPath).removeDuplicates().eraseToAnyPublisher()
    }
}

// MARK: - Binding helpers

extension Binding where Value: Equatable {
    func dispatched<State>(to store: Store<State>, _ keyPath: WritableKeyPath<State, Value>) -> Self {
        onSet { store[keyPath] = $0 }
    }

    func onSet(_ perform: @escaping (Value) -> Void) -> Self {
        Binding(
            get: { wrappedValue },
            set: {
                if wrappedValue != $0 {
                    wrappedValue = $0
                }
                perform($0)
            }
        )
    }
}
