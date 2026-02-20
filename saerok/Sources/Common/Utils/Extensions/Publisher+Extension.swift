//
//  Publisher+Extension.swift
//  saerok
//
//  Created by HanSeung on 12/9/25.
//

import Combine

extension Publisher where Failure == Never {
    func weakAssign<Object: AnyObject>(
        to keyPath: ReferenceWritableKeyPath<Object, Output>,
        on object: Object
    ) -> AnyCancellable {
        sink { [weak object] value in
            object?[keyPath: keyPath] = value
        }
    }

    func weakSink<T: AnyObject>(
        on object: T,
        receiveValue: @escaping (T, Output) -> Void
    ) -> AnyCancellable {
        sink { [weak object] value in
            guard let object else { return }
            receiveValue(object, value)
        }
    }
}
