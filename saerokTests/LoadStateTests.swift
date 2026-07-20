import Testing
@testable import saerok

// MARK: - LoadState Tests

@Suite("LoadState")
struct LoadStateTests {

    @Test("아직 요청하지 않은 상태에서는 값이 nil이다")
    func notRequestedValueIsNil() {
        let state: LoadState<Int> = .notRequested
        #expect(state.value == nil)
    }

    @Test("로딩 중인 상태에서는 값이 없고 로딩 여부만 참이다")
    func loadingState() {
        let state: LoadState<Int> = .loading
        #expect(state.value == nil)
        #expect(state.isLoading == true)
        #expect(state.inError == false)
    }

    @Test("성공 상태에서는 값을 반환하고 로딩·에러 여부는 거짓이다")
    func successState() {
        let state: LoadState<Int> = .success(42)
        #expect(state.value == 42)
        #expect(state.isLoading == false)
        #expect(state.inError == false)
    }

    @Test("실패 상태에서는 에러 여부가 참이고 값은 nil이다")
    func failureState() {
        struct TestError: Error {}
        let state: LoadState<Int> = .failure(TestError())
        #expect(state.value == nil)
        #expect(state.isLoading == false)
        #expect(state.inError == true)
    }

    @Test("Void 타입이 성공 상태일 때 값은 nil이 아니다")
    func voidSuccessValueIsNonNil() {
        let state: LoadState<Void> = .success(())
        #expect(state.value != nil)
    }

    @Test("Void 타입이 로딩 상태일 때 값은 nil이다")
    func voidLoadingValueIsNil() {
        let state: LoadState<Void> = .loading
        #expect(state.value == nil)
    }

    @Test("load 작업이 성공하면 성공 상태와 결과 값을 반환한다")
    func loadSuccess() async {
        var state: LoadState<Int> = .notRequested
        let result = await state.load { 99 }
        #expect(result.value == 99)
    }

    @Test("load 작업이 에러를 던지면 실패 상태를 반환한다")
    func loadFailure() async {
        struct TestError: Error {}
        var state: LoadState<Int> = .notRequested
        let result = await state.load { throw TestError() }
        #expect(result.inError == true)
    }
}
