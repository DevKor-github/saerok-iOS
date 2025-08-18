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
    
    var timeAgoText: String {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .hour, .minute], from: self, to: now)
        
        if let day = components.day, day >= 14 {
            return self.korString
        } else if let day = components.day, day > 0 {
            return "\(day)일 전"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour)시간 전"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute)분 전"
        } else {
            return "방금 전"
        }
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
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul") 
        return formatter
    }()
}
