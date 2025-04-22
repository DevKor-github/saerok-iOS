//
//  Date+Extension.swift
//  saerok
//
//  Created by HanSeung on 4/22/25.
//


import Foundation

extension Date {
    private func toString(format: String = "yyyy.MM.dd") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = format
        return formatter.string(from: self)
    }

    var toShortString: String {
        return toString(format: "MM.dd")
    }

    var toFullString: String {
        return toString(format: "yyyy.MM.dd")
    }
}
