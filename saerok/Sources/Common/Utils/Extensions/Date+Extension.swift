//
//  Date+Extension.swift
//  saerok
//
//  Created by HanSeung on 4/22/25.
//

import Foundation

extension Date {

    /// 기준 날짜(self)부터 오늘까지 며칠이 지났는지 반환
    ///
    /// - Example:
    /// ```swift
    /// let date = Date(timeIntervalSinceNow: -86400 * 3)
    /// date.daysSince // 3
    /// ```
    var daysSince: Int {
        let calendar = Calendar.current
        let startOfFrom = calendar.startOfDay(for: self)
        let startOfSelf = calendar.startOfDay(for: .now)
        let components = calendar.dateComponents([.day], from: startOfFrom, to: startOfSelf)
        return components.day ?? 0
    }

    /// 날짜를 `MM.dd` 형식 문자열로 변환
    ///
    /// - Example:
    /// ```swift
    /// // 2024-10-12
    /// date.toShortString // "10.12"
    /// ```
    var toShortString: String {
        return toString(format: "MM.dd")
    }

    /// 날짜를 `yyyy.MM.dd` 형식 문자열로 변환
    ///
    /// - Example:
    /// ```swift
    /// // 2024-10-12
    /// date.toFullString // "2024.10.12"
    /// ```
    var toFullString: String {
        return toString(format: "yyyy.MM.dd")
    }

    /// 날짜를 한국어 전체 날짜 문자열로 변환
    ///
    /// - Example:
    /// ```swift
    /// // 2024-10-12
    /// date.korString // "2024년 10월 12일"
    /// ```
    var korString: String {
        return toString(format: "yyyy년 MM월 dd일")
    }

    /// 서버 업로드용 날짜 문자열 (`yyyy-MM-dd`)
    ///
    /// - Example:
    /// ```swift
    /// // 2024-10-12
    /// date.toUploadType // "2024-10-12"
    /// ```
    var toUploadType: String {
        return toString(format: "yyyy-MM-dd")
    }

    /// 현재 시점 기준 상대 시간 문자열
    ///
    /// - Rules:
    /// - 14일 이상: 날짜 표시
    /// - 1일 이상: "N일 전"
    /// - 1시간 이상: "N시간 전"
    /// - 1분 이상: "N분 전"
    /// - 그 외: "방금 전"
    ///
    /// - Example:
    /// ```swift
    /// Date(timeIntervalSinceNow: -60).timeAgoText      // "1분 전"
    /// Date(timeIntervalSinceNow: -3600).timeAgoText   // "1시간 전"
    /// Date(timeIntervalSinceNow: -86400).timeAgoText  // "1일 전"
    /// ```
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

    /// 날짜를 영어 Long Date 형식으로 변환
    ///
    /// - Example:
    /// ```swift
    /// // 2024-10-12
    /// date.toEnglishLongString() // "12 October, 2024"
    /// ```
    func toEnglishLongString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "d MMMM, yyyy"
        return formatter.string(from: self)
    }

    /// `yyyy-MM-dd` 형식 문자열을 Date로 변환
    ///
    /// - Example:
    /// ```swift
    /// Date.fromSimpleDateString("2024-10-12")
    /// ```
    static func fromSimpleDateString(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: string)
    }

    /// 내부 날짜 포맷 공통 변환 함수
    private func toString(format: String = "yyyy.MM.dd") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

extension DateFormatter {

    /// ISO8601 (마이크로초 포함) 포맷
    ///
    /// - Format: `yyyy-MM-dd'T'HH:mm:ss.SSSSSS`
    /// - TimeZone: Asia/Seoul
    ///
    /// - Example:
    /// ```swift
    /// "2024-10-12T09:00:00.123456"
    /// ```
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter
    }()
}

extension DateFormatter {

    /// ISO8601 기본 포맷 (초 단위)
    ///
    /// - Format: `yyyy-MM-dd'T'HH:mm:ss`
    /// - TimeZone: Asia/Seoul
    ///
    /// - Example:
    /// ```swift
    /// "2024-10-12T09:00:00"
    /// ```
    static let iso8601Basic: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter
    }()
}

extension JSONDecoder {
    static func withFlexibleISO8601() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)

            for formatter in DateFormatter.flexibleISO8601 {
                if let date = formatter.date(from: string) {
                    return date
                }
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid date format: \(string)"
            )
        }
        return decoder
    }
}

extension DateFormatter {
    static let flexibleISO8601: [DateFormatter] = [
        {
            let f = DateFormatter()
            f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
            f.locale = Locale(identifier: "en_US_POSIX")
            f.timeZone = TimeZone(identifier: "Asia/Seoul")
            return f
        }(),
        {
            let f = DateFormatter()
            f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            f.locale = Locale(identifier: "en_US_POSIX")
            f.timeZone = TimeZone(identifier: "Asia/Seoul")
            return f
        }()
    ]
}
