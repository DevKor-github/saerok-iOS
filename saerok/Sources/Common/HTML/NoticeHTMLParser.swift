//
//  NoticeHTMLParser.swift
//  saerok
//
//  Created by HanSeung on 2/4/26.
//

import Foundation

enum RichNode {
    case h1([InlineNode])
    case h2([InlineNode])
    case p([InlineNode])
    case ul([[InlineNode]])
    case ol([[InlineNode]])
    case img(URL)
    case br
}

enum InlineNode {
    case text(String)
    case bold(String)
    case italic(String)
    case underline(String)
    case link(text: String, url: URL)
}

enum NoticeHTMLParser {

    // MARK: - Static Regex (한 번만 생성, 실패 시 패턴 오류이므로 fatalError)

    private static let blockRegex: NSRegularExpression = {
        guard let r = try? NSRegularExpression(
            pattern: "<(h1|h2|p|ul|ol)\\b[^>]*>(.*?)</\\1>|<br\\s*/?>",
            options: [.dotMatchesLineSeparators, .caseInsensitive]
        ) else { fatalError("blockRegex 패턴 오류") }
        return r
    }()

    private static let liRegex: NSRegularExpression = {
        guard let r = try? NSRegularExpression(
            pattern: "<li\\b[^>]*>(.*?)</li>",
            options: [.dotMatchesLineSeparators, .caseInsensitive]
        ) else { fatalError("liRegex 패턴 오류") }
        return r
    }()

    private static let inlineRegex: NSRegularExpression = {
        guard let r = try? NSRegularExpression(
            pattern: "<(strong|em|u|a)\\b([^>]*)>(.*?)</\\1>|([^<]+)",
            options: [.dotMatchesLineSeparators, .caseInsensitive]
        ) else { fatalError("inlineRegex 패턴 오류") }
        return r
    }()

    private static let hrefRegex: NSRegularExpression = {
        guard let r = try? NSRegularExpression(pattern: "href=\"(.*?)\"", options: []) else {
            fatalError("hrefRegex 패턴 오류")
        }
        return r
    }()

    private static let imgRegex: NSRegularExpression = {
        guard let r = try? NSRegularExpression(
            pattern: "<img\\b[^>]*src=\"(.*?)\"",
            options: .caseInsensitive
        ) else { fatalError("imgRegex 패턴 오류") }
        return r
    }()

    // MARK: - Parse

    static func parse(_ html: String) -> [RichNode] {
        var result: [RichNode] = []

        let matches = blockRegex.matches(
            in: html,
            range: NSRange(html.startIndex..., in: html)
        )

        for match in matches {

            // <br />
            if match.range(at: 1).location == NSNotFound {
                result.append(.br)
                continue
            }

            let tag = html[match.range(at: 1)].lowercased()
            let body = html[match.range(at: 2)].trimmingCharacters(in: .whitespacesAndNewlines)

            // <p><br></p>
            if tag == "p", body == "<br>" || body == "<br/>" {
                result.append(.br)
                continue
            }

            // <p><img ...></p>
            if tag == "p", let imgURL = extractImgSrc(from: body) {
                result.append(.img(imgURL))
                continue
            }

            switch tag {
            case "h1":
                result.append(.h1(parseInline(body)))
            case "h2":
                result.append(.h2(parseInline(body)))
            case "p":
                result.append(.p(parseInline(body)))
            case "ul":
                result.append(.ul(parseList(body)))
            case "ol":
                result.append(.ol(parseList(body)))
            default:
                break
            }
        }

        return result
    }

    // MARK: - List

    private static func parseList(_ html: String) -> [[InlineNode]] {
        liRegex.matches(
            in: html,
            range: NSRange(html.startIndex..., in: html)
        ).map {
            parseInline(html[$0.range(at: 1)])
        }
    }

    // MARK: - Inline

    private static func parseInline(_ html: String) -> [InlineNode] {
        var nodes: [InlineNode] = []

        let matches = inlineRegex.matches(
            in: html,
            range: NSRange(html.startIndex..., in: html)
        )

        for m in matches {

            // plain text
            if m.range(at: 4).location != NSNotFound {
                let text = html[m.range(at: 4)]
                if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    nodes.append(.text(text))
                }
                continue
            }

            let tag = html[m.range(at: 1)].lowercased()
            let attr = html[m.range(at: 2)]
            let content = html[m.range(at: 3)]

            switch tag {
            case "strong":
                nodes.append(.bold(content))
            case "em":
                nodes.append(.italic(content))
            case "u":
                nodes.append(.underline(content))
            case "a":
                if let url = extractHref(from: attr) {
                    nodes.append(.link(text: content, url: url))
                } else {
                    nodes.append(.text(content))
                }
            default:
                break
            }
        }

        return nodes
    }

    // MARK: - Utils

    private static func extractHref(from attr: String) -> URL? {
        guard let match = hrefRegex.firstMatch(in: attr, range: NSRange(attr.startIndex..., in: attr)) else {
            return nil
        }
        return URL(string: attr[match.range(at: 1)])
    }

    private static func extractImgSrc(from html: String) -> URL? {
        guard let match = imgRegex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)) else {
            return nil
        }
        return URL(string: html[match.range(at: 1)])
    }
}
