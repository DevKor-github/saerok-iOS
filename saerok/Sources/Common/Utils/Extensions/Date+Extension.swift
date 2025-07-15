//
//  Date+Extension.swift
//  saerok
//
//  Created by HanSeung on 4/22/25.
//


import Foundation

extension Date {
    var daysSince: Int {
        let calendar = Calendar.current
        let startOfFrom = calendar.startOfDay(for: self)
        let startOfSelf = calendar.startOfDay(for: .now)
        let components = calendar.dateComponents([.day], from: startOfFrom, to: startOfSelf)
        return components.day ?? 0
    }

    var toShortString: String {
        return toString(format: "MM.dd")
    }

    var toFullString: String {
        return toString(format: "yyyy.MM.dd")
    }
    
    var korString: String {
        return toString(format: "yyyy년 MM월 dd일")
    }
    
    var toUploadType: String {
        return toString(format: "yyyy-MM-dd")
    }
    
    func toEnglishLongString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "d MMMM, yyyy"
        return formatter.string(from: self)
    }
    
    static func fromSimpleDateString(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: string)
    }
    
    private func toString(format: String = "yyyy.MM.dd") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

extension DateFormatter {
    static let collectionComment: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // 서버 시간대에 따라 조정
        return formatter
    }()
}
