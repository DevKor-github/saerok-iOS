//
//  TabItemView.swift
//  saerok
//
//  Created by HanSeung on 3/20/25.
//

import SwiftUI

struct TabItemView: View {
    let imageName: String
    let title: String
    let isActive: Bool
    
    init(imageName: String, title: String, isActive: Bool) {
        self.imageName = imageName
        self.title = title
        self.isActive = isActive
    }
    
    var body: some View {
        HStack(spacing: 10) {
            Spacer()
            Image(systemName: imageName)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(isActive ? .white : .gray)
                .frame(width: 20, height: 20)
            if isActive {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(isActive ? .white : .gray)
            }
            Spacer()
        }
        .frame(height: 60)
        .frame(width: isActive ? 140 : 60)
        .background(isActive ? .orange : .clear)
        .cornerRadius(30)
    }
}
