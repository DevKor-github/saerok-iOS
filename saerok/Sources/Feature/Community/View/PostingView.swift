//
//  PostingView.swift
//  saerok
//
//  Created by HanSeung on 3/10/26.
//

import SwiftUI

struct PostingView: View {
//    @EnvironmentObject private var coordinator: AppCoordinator
    
    let me: Local.User = .init(userId: 1, nickname: "비둘기", profileImageUrl: "https://stickershop.line-scdn.net/stickershop/v1/product/1665280/LINEStorePC/main.png?v=1")
    
    @State private var title: String = ""
    @State private var contents: String = ""
    @State private var isUploading: Bool = false
    
    var body: some View {
        content
            .regainSwipeBack()
            .modifier(FloatingMenuModifier(postAction: {}, saerokAction: {}, bottomOffset: 24))
    }
    
    @ViewBuilder
    var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            navigationBar
            Divider()
                .background(Color.whiteGray)
                .frame(height: 1)
            Group {
                userView
                    .padding(.top, 13)
                TextField("자유로운 글을 작성해보세요!", text: $contents)
                    .font(.SRFontSet.body4_2)
                    .padding(.leading, 30)
                    .padding(.top, 3)
                Spacer()
                Button(action : { isUploading.toggle() }) {
                    if isUploading {
                        ProgressView()
                    } else {
                        Text("게시하기")
                    }
                }
                .srStyled(.primaryButton)
                .disabled(isUploading)
            }
            .padding(.horizontal, 24)
        }
    }
}

private extension PostingView {
    var navigationBar: some View {
        NavigationBar(
            center: {
                Text("자유게시판")
                    .font(.SRFontSet.subtitle2)
            }, leading: {
                Button {
//                    coordinator.pop()
                } label: {
                    Image.SRIconSet.chevronLeft
                        .frame(.defaultIconSize)
                }
                .srStyled(.borderedIconButton)
            })
    }
    
    var userView: some View {
        HStack(spacing: 5) {
            ReactiveAsyncImage(
                url: me.profileImageUrl,
                scale: .small,
                size: .init(width: 25, height: 25),
                downsampling: true
            )
            .srAvatarStyle()
            Text(me.nickname)
                .font(.SRFontSet.body3_2)
        }
    }
}

#Preview {
    PostingView()
}
