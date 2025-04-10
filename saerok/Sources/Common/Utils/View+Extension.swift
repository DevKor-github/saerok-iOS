extension View {
    /// 디버깅용 테두리: 빨간색 테두리를 뷰에 표시합니다.
    func debugBorder(_ color: Color = .red, width: CGFloat = 1) -> some View {
        self.border(color, width: width)
    }
}