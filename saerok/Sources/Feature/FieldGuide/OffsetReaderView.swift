private struct OffsetReaderView: View {
    var body: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(key: ScrollPreferenceKey.self, value: proxy.frame(in: .global).minY)
        }
        .frame(height: 0)
    }
}