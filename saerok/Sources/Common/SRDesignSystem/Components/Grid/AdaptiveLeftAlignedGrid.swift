//
//  AdaptiveLeftAlignedGrid.swift
//  saerok
//
//  Created by HanSeung on 5/27/25.
//


import SwiftUI

struct AdaptiveLeftAlignedGrid<Item: Hashable, Content: View>: View {
    var items: [Item]
    var minCellWidth: CGFloat
    var spacing: CGFloat
    var content: (Item) -> Content

    var body: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let rowItems = computeRows(containerWidth: totalWidth)

            VStack(alignment: .leading, spacing: spacing) {
                ForEach(rowItems.indices, id: \.self) { rowIndex in
                    HStack(spacing: spacing) {
                        ForEach(rowItems[rowIndex], id: \.self) { item in
                            content(item)
                        }
                    }
                }
            }
        }
    }

    private func computeRows(containerWidth: CGFloat) -> [[Item]] {
        var rows: [[Item]] = [[]]
        var currentRowWidth: CGFloat = 0

        for item in items {
            let estimatedWidth = minCellWidth

            if currentRowWidth + estimatedWidth + spacing > containerWidth {
                rows.append([item])
                currentRowWidth = estimatedWidth + spacing
            } else {
                rows[rows.count - 1].append(item)
                currentRowWidth += estimatedWidth + spacing
            }
        }

        return rows
    }
}
