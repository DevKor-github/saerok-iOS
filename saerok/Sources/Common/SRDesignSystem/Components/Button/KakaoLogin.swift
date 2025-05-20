//
//  KakaoLogin.swift
//  saerok
//
//  Created by HanSeung on 5/18/25.
//


import SwiftUI

struct KakaoLogin: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .center) {
                Spacer()
                Image(.kakao)
                    .resizable()
                    .frame(width: 20, height: 20)
                Text("카카오 로그인")
                    .font(.system(size: 18))
                    .foregroundStyle(.black)
                    .opacity(0.85)
                Spacer()
            }
            .frame(height: 54)
            .background(Color.kakao)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}
