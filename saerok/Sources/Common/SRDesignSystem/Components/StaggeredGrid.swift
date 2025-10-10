//
//  StaggeredGrid.swift
//  saerok
//
//  Created by HanSeung on 5/23/25.
//


import SwiftUI

struct StaggeredGrid<Content: View, T: Hashable, Header: View>: View {
    var items: [T]
    var columns: Int
    var spacing: CGFloat
    var header: (() -> Header)?
    var content: (T) -> Content
    
    init(
        items: [T],
        columns: Int,
        spacing: CGFloat = 8,
        @ViewBuilder header: () -> Header? = { nil },
        @ViewBuilder content: @escaping (T) -> Content
    ) {
        self.items = items
        self.columns = columns
        self.spacing = spacing
        self.content = content
    }
    
    private func generateColumns() -> [[T]] {
        var grid: [[T]] = Array(repeating: [], count: columns)
        var heights: [CGFloat] = Array(repeating: 0, count: columns)
        
        for item in items {
            if let minIndex = heights.enumerated().min(by: { $0.element < $1.element })?.offset {
                grid[minIndex].append(item)
                heights[minIndex] += 1
            }
        }
        return grid
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: spacing) {
            ForEach(Array(generateColumns().enumerated()), id: \.offset) { colIndex, columnItems in
                LazyVStack(spacing: spacing) {
                    ForEach(Array(columnItems.enumerated()), id: \.element.hashValue) { rowIndex, item in
                        if colIndex == 0 && rowIndex == 0, let header = header {
                            header()
                        } else {
                            content(item)
                        }
                    }

                    Group {
                        Rectangle()
                        Rectangle()
                    }
                    .foregroundStyle(.clear)
                    .frame(height: 150)
                }
            }
        }
        .padding(.vertical)
    }
}
