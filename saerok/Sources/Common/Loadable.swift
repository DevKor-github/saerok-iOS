//
//  Loadable.swift
//  saerok
//
//  Created by HanSeung on 4/8/25.
//

import Combine
import Foundation
import SwiftUI

enum LoadState<T> {
    case notRequested
    case loading
    case success(T)
    case failure(Error)
    
    var value: T? {
        if case .success(let value) = self {
            return value
        }
        return nil
    }
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    var inError: Bool {
        if case .failure(_) = self {
            return true
        }
        return false
    }
    
    var description: String {
        switch self {
        case .notRequested:
            "notRequested"
        case .loading:
            "loading"
        case .success(let t):
            "success\(t)"
        case .failure(let error):
            "failure\(error.localizedDescription)"
        }
    }
}

extension LoadState {
    mutating func load(operation: () async throws -> T) async -> LoadState<T> {
        self = .loading
        do {
            let value = try await operation()
            return .success(value)
        } catch {
            return .failure(error)
        }
    }
}

extension LoadState: Equatable where T: Equatable {
    static func == (lhs: LoadState<T>, rhs: LoadState<T>) -> Bool {
        switch (lhs, rhs) {
        case (.notRequested, .notRequested): return true
        case (.loading, .loading): return true
        case let (.success(lhsV), .success(rhsV)): return lhsV == rhsV
        case let (.failure(lhsE), .failure(rhsE)):
            return lhsE.localizedDescription == rhsE.localizedDescription
        default: return false
        }
    }
}

//enum Loadable<T> {
//    case notRequested
//    case isLoading(last: T?, cancelBag: CancelBag)
//    case loaded(T)
//    case failed(Error)
//    
//    var value: T? {
//        switch self {
//        case .loaded(let value): return value
//        case .isLoading(let last, _): return last
//        default: return nil
//        }
//    }
//    
//    var error: Error? {
//        switch self {
//        case .failed(let error): return error
//        default: return nil
//        }
//    }
//}
//
//extension Loadable {
//    mutating func setIsLoading(cancelBag: CancelBag) {
//        self = .isLoading(last: value, cancelBag: cancelBag)
//    }
//    
//    mutating func cancelLoading() {
//        switch self {
//        case .isLoading(let last, let cancelBag):
//            cancelBag.cancel()
//            if let last = last {
//                self = .loaded(last)
//            } else {
//                let error = NSError(
//                    domain: NSCocoaErrorDomain, code: NSUserCancelledError,
//                    userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Canceled by user", comment: "")])
//                self = .failed(error)
//            }
//        default: break
//        }
//    }
//    
//    func map<V>(_ transform: (T) throws -> V) -> Loadable<V> {
//        do {
//            switch self {
//            case .notRequested:
//                return .notRequested
//            case .failed(let error):
//                return .failed(error)
//            case .isLoading(let value, let cancelBag):
//                return .isLoading(last: try value.map { try transform($0) }, cancelBag: cancelBag)
//            case .loaded(let value):
//                return .loaded(try transform(value))
//            }
//        } catch {
//            return .failed(error)
//        }
//    }
//}
//
//protocol SomeOptional {
//    associatedtype Wrapped
//    func unwrap() throws -> Wrapped
//}
//
//struct ValueIsMissingError: Error {
//    var localizedDescription: String {
//        NSLocalizedString("Data is missing", comment: "")
//    }
//}
//
//extension Optional: SomeOptional {
//    func unwrap() throws -> Wrapped {
//        switch self {
//        case .some(let value): return value
//        case .none: throw ValueIsMissingError()
//        }
//    }
//}
//
//extension Loadable where T: SomeOptional {
//    func unwrap() -> Loadable<T.Wrapped> {
//        map { try $0.unwrap() }
//    }
//}
//
