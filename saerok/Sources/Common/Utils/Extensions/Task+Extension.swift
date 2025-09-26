//
//  Task+Extension.swift
//  saerok
//
//  Created by HanSeung on 9/17/25.
//

extension Task where Failure == Never {
    @discardableResult
    static func debounce(
        id: String,
        delay: UInt64 = 800_000_000,
        tasks debounceTasks: inout [String: Task<Void, Never>],
        action: @escaping () async throws -> Void
    ) -> Task<Void, Never> {
        debounceTasks[id]?.cancel()

        let task = Task<Void, Never> {
            do {
                try await Task<Never, Never>.sleep(nanoseconds: delay)
                try await action()
            } catch {
                if !(error is CancellationError) {
                    print("Debounce Error:", error)
                }
            }
        }
        debounceTasks[id] = task
        return task
    }
}
