protocol BaseView: View {
    associatedtype Routing: Equatable
    var routingState: Routing { get set }
    var routingBinding: Binding<Routing> { get }
    var routingUpdate: AnyPublisher<Routing, Never> { get }
}

extension BaseView {
    var routingBinding: Binding<Routing> {
        fatalError("Must override routingBinding in your View")
    }

    var routingUpdate: AnyPublisher<Routing, Never> {
        Empty().eraseToAnyPublisher()
    }
}