//
//  String+Extension.swift
//  saerok
//
//  Created by HanSeung on 5/16/25.
//

import Foundation

extension String {
    func allowLineBreaking() -> String {
        return self.map { String($0) }.joined(separator: "\u{200B}")
    }
}

extension String {
    func highlighted(keyword: String) -> AttributedString {
        var attributed = AttributedString(self)
        guard !keyword.isEmpty else { return attributed }
        
        let lowercasedText = self.lowercased()
        let lowercasedKeyword = keyword.lowercased()
        
        if let range = lowercasedText.range(of: lowercasedKeyword) {
            let nsRange = NSRange(range, in: self)
            if let swiftRange = Range(nsRange, in: attributed) {
                attributed[swiftRange].foregroundColor = .blue
            }
        }
        
        return attributed
    }
}

extension String {
    /// NSRange(UTF-16 기반)를 Swift String Range로 변환
    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let fromUTF16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let toUTF16 = utf16.index(fromUTF16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = String.Index(fromUTF16, within: self),
            let to = String.Index(toUTF16, within: self)
        else {
            return nil
        }
        return from..<to
    }
    
    /// string[nsRange] 형태로 쓰기 위한 서브스크립트
    subscript(nsRange: NSRange) -> String {
        guard let range = range(from: nsRange) else { return "" }
        return String(self[range])
    }
}
