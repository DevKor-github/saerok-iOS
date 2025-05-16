//
//  String+Extension.swift
//  saerok
//
//  Created by HanSeung on 5/16/25.
//


extension String {
    func allowLineBreaking() -> String {
        return self.map { String($0) }.joined(separator: "\u{200B}")
    }
}