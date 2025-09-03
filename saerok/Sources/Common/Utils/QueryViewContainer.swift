//
//  QueryViewContainer.swift
//  saerok
//
//  Created by HanSeung on 4/8/25.
//


import SwiftData
import SwiftUI

extension View {
    func query<T: PersistentModel, Key: Equatable>(
        key: Key,
        results: Binding<[T]>,
        _ builder: @escaping (Key) -> Query<T, [T]>
    ) -> some View {
        background {
            QueryViewContainer(key: key, builder: builder) { _, values in
                results.wrappedValue = values
            }
            .equatable()
        }
    }
}

/// SwiftData의 `@Query`가 불필요하게 여러 번 호출되는 것을 방지하기 위한 래퍼 뷰입니다.
///
/// `searchText`가 변경되지 않는 한 SwiftUI가 `QueryView`를 재생성하지 않도록
/// `Equatable`을 통해 렌더링을 제어합니다.
private struct QueryViewContainer<T: PersistentModel, Key: Equatable>: View, Equatable {
    let key: Key
    let builder: (Key) -> Query<T, [T]>
    let results: ([T], [T]) -> Void

    var body: some View {
        QueryView(query: builder(key), results: results)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.key == rhs.key
    }
}

/// `QueryViewContainer`에 의해 감싸져  중복 쿼리를 방지하는 비가시적 View입니다.
///
/// View 계층에 영향 없이, 배경에서 데이터 업데이트를 감지합니다.
private struct QueryView<T: PersistentModel>: View {
    @Query var query: [T]
    let results: ([T], [T]) -> Void

    init(query: Query<T, [T]>, results: @escaping ([T], [T]) -> Void) {
        _query = query
        self.results = results
    }

    var body: some View {
        Rectangle()
            .hidden()
            .onChange(of: query, initial: true, results)
    }
}
