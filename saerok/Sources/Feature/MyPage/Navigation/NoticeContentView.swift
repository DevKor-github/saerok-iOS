//
//  NoticeContentView.swift
//  saerok
//
//  Created by HanSeung on 2/4/26.
//

import SwiftUI

struct NoticeContentView: View {
    let nodes: [RichNode]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(nodes.enumerated()), id: \.offset) { _, node in
                render(node)
            }
        }
    }
    
    @ViewBuilder
    private func render(_ node: RichNode) -> some View {
        switch node {
        case .h1(let inlines):
            inlineText(inlines).font(.title)

        case .h2(let inlines):
            inlineText(inlines).font(.title2)

        case .p(let inlines):
            inlineText(inlines)

        case .ul(let items):
            VStack(alignment: .leading) {
                ForEach(items.indices, id: \.self) { i in
                    HStack(alignment: .top) {
                        Text("•")
                        inlineText(items[i])
                    }
                }
            }

        case .ol(let items):
            VStack(alignment: .leading) {
                ForEach(items.indices, id: \.self) { i in
                    HStack(alignment: .top) {
                        Text("\(i + 1).")
                        inlineText(items[i])
                    }
                }
            }

        case .img(let url):
            ReactiveAsyncImage(url: url.absoluteString, scale: .small, size: .zero, downsampling: true)
                .scaledToFit()

        case .br:
            Spacer().frame(height: 8)
        }
    }
    
    private func inlineText(_ nodes: [InlineNode]) -> Text {
        var result = AttributedString()

        for node in nodes {
            result.append(attributed(for: node))
        }

        return Text(result)
    }

    private func attributed(for node: InlineNode) -> AttributedString {
        switch node {

        case .text(let s):
            return AttributedString(s)

        case .bold(let s):
            var a = AttributedString(s)
            a.font = .system(.body).bold()
            return a

        case .italic(let s):
            do {
                var a = try AttributedString(markdown: "*\(s)*")
                a.font = .system(.body)
                return a
            } catch {
                var a = AttributedString(s)
                a.font = .system(.body).italic()
                return a
            }

        case .underline(let s):
            var a = AttributedString(s)
            a.underlineStyle = .single
            return a

        case .link(let t, let url):
            var a = AttributedString(t)
            a.foregroundColor = .blue
            a.underlineStyle = .single
            a.link = url
            return a
        }
    }
    
    private func text(for node: InlineNode) -> Text {
        switch node {
        case .text(let s): return Text(s)
        case .bold(let s): return Text(s).bold()
        case .italic(let s): return Text(s).italic()
        case .underline(let s): return Text(s).underline()
        case .link(let t, _):
            return Text(t).foregroundColor(.blue).underline()
        }
    }
}
