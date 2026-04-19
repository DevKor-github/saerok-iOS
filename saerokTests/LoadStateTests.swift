import Testing
@testable import saerok

// MARK: - LoadState Tests

@Suite("LoadState")
struct LoadStateTests {

    @Test("notRequested: value는 nil")
    func notRequestedValueIsNil() {
        let state: LoadState<Int> = .notRequested
        #expect(state.value == nil)
    }

    @Test("loading: value는 nil, isLoading은 true")
    func loadingState() {
        let state: LoadState<Int> = .loading
        #expect(state.value == nil)
        #expect(state.isLoading == true)
        #expect(state.inError == false)
    }

    @Test("success: value 반환, isLoading false")
    func successState() {
        let state: LoadState<Int> = .success(42)
        #expect(state.value == 42)
        #expect(state.isLoading == false)
        #expect(state.inError == false)
    }

    @Test("failure: inError true, value nil")
    func failureState() {
        struct TestError: Error {}
        let state: LoadState<Int> = .failure(TestError())
        #expect(state.value == nil)
        #expect(state.isLoading == false)
        #expect(state.inError == true)
    }

    @Test("Void LoadState: success(()) value는 non-nil")
    func voidSuccessValueIsNonNil() {
        let state: LoadState<Void> = .success(())
        #expect(state.value != nil)
    }

    @Test("Void LoadState: loading일 때 value는 nil")
    func voidLoadingValueIsNil() {
        let state: LoadState<Void> = .loading
        #expect(state.value == nil)
    }

    @Test("load: 성공 시 .success 반환")
    func loadSuccess() async {
        var state: LoadState<Int> = .notRequested
        let result = await state.load { 99 }
        #expect(result.value == 99)
    }

    @Test("load: 실패 시 .failure 반환")
    func loadFailure() async {
        struct TestError: Error {}
        var state: LoadState<Int> = .notRequested
        let result = await state.load { throw TestError() }
        #expect(result.inError == true)
    }
}
