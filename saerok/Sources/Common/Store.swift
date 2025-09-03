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

// MARK: - Binding 헬퍼

extension Binding where Value: Equatable {
    
    /// 뷰에서 바인딩된 값이 변경될 때 Store(State)로 값을 전파합니다.
    ///
    /// `@Binding`을 AppState와 동기화시키기 위해 사용합니다.
    ///  
    /// - Parameters:
    ///   - store: 상태를 저장하고 관리하는 Store 객체
    ///   - keyPath: 변경할 Store 내부 상태의 KeyPath
    /// - Returns: 업데이트 시 상태와 동기화되는 새로운 Binding
    func dispatched<State>(to store: Store<State>, _ keyPath: WritableKeyPath<State, Value>) -> Self {
        onSet { store[keyPath] = $0 }
    }

    /// Binding 값이 변경될 때 특정 동작을 수행할 수 있게 합니다.
    ///
    /// 변경 감지를 통해 로깅, 유효성 검사, 외부 액션 트리거 등에 활용할 수 있습니다.
    ///
    /// - Parameter perform: 값이 설정(set)될 때 호출할 클로저
    /// - Returns: set 시 부가 동작이 수행되는 새로운 Binding
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
