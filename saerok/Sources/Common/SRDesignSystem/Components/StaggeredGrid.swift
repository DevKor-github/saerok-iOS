//
//  StaggeredGrid.swift
//  saerok
//
//  Created by HanSeung on 5/23/25.
//


import SwiftUI

struct StaggeredGrid<Content: View, T: Hashable>: View {
    var items: [T]
    var columns: Int
    var spacing: CGFloat
    var content: (T) -> Content
    
    init(items: [T], columns: Int, spacing: CGFloat = 8, @ViewBuilder content: @escaping (T) -> Content) {
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
            ForEach(generateColumns(), id: \.self) { columnItems in
                VStack(spacing: spacing) {
                    ForEach(columnItems, id: \.hashValue) { item in
                        content(item)
                    }
                    
                    Group {
                        Rectangle()
                        Rectangle()
                    }
                    .foregroundStyle(.clear)
                    .frame(height: 200)
                }
            }
        }
        .padding(.vertical)
    }
}
