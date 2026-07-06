//
//  SettingItemView.swift
//  saerok
//
//  Created by HanSeung on 6/14/25.
//

import SwiftUI

extension MyPageView {
    struct SettingItemView: View {
        var title: String
        var icon: Image.SRIconSet
        var trailing: AnyView?
        var onTap: () -> Void
        
        init(
            title: String,
            icon: Image.SRIconSet,
            trailing: AnyView? = nil,
            onTap: @escaping () -> Void,
            isDisabled: Bool = false
        ) {
            self.title = title
            self.icon = icon
            self.trailing = trailing
            self.onTap = onTap
        }
        
        var body: some View {
            Button(action: onTap) {
                HStack {
                    HStack {
                        icon.frame(.large, tintColor: .pointtext)
                        Text(title)
                            .font(.SRFontSet.body2)
                    }
                    .srStyled(.chip(background: .srLightGray))
                    
                    Spacer()
                    if let trailing = trailing {
                        trailing
                    } else {
                        Image.SRIconSet.chevronRight
                            .frame(.small)
                            .foregroundStyle(.secondary)
                    }
                }
                .foregroundStyle(.black)
                
            }
            .contentShape(Rectangle())
        }
    }
}
