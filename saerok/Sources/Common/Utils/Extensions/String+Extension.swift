extension String {
    func allowLineBreaking() -> String {
        return self.map { String($0) }.joined(separator: "\u{200B}")
    }
}