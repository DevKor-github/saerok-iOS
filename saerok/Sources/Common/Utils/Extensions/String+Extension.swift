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
