//
//  FloatingMenuModifier.swift
//  saerok
//
//  Created by HanSeung on 3/11/26.
//

import SwiftUI

struct FloatingMenuModifier: ViewModifier {
    let postAction: () -> Void
    let saerokAction: () -> Void
    let bottomOffset: CGFloat

    @Binding var showMenu: Bool
    @Binding var isHidden: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay {
                ZStack {
                    Color.black
                        .opacity(showMenu ? 0.5 : 0)
                        .ignoresSafeArea()
                        .animation(.easeInOut(duration: 0.2), value: showMenu)
                        .allowsHitTesting(showMenu)
                        .onTapGesture {
                            showMenu = false
                        }
                    
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            FloatingMenuView(
                                showMenu: $showMenu,
                                postAction: postAction,
                                saerokAction: saerokAction
                            )
                            .padding(.trailing, 23)
                            .padding(.bottom, bottomOffset)
                            .opacity(isHidden ? 0 : 1)
                        }
                    }
                }
            }
    }
}

struct FloatingMenuView: View {
    @Binding var showMenu: Bool
    let postAction: () -> Void
    let saerokAction: () -> Void
    
    private let springAnimation: Animation = .spring(response: 0.35, dampingFraction: 0.9)
    
    var body: some View {
        ZStack {
            Button {
                saerokAction()
                showMenu.toggle()
            } label: {
                Image(.comAddsaerokButton)
                    .resizable()
                    .frame(width: 62, height: 62)
            }
            .offset(x: showMenu ? -10 : 0, y: showMenu ? -80 : 0)
            .opacity(showMenu ? 1 : 0)
            .scaleEffect(showMenu ? 1 : 0.3)
            .animation(springAnimation, value: showMenu)

            Button {
                postAction()
                showMenu.toggle()
            } label: {
                Image(.comPostButton)
                    .resizable()
                    .frame(width: 62, height: 62)
            }
            .offset(x: showMenu ? -80 : 0, y: showMenu ? -10 : 0)
            .opacity(showMenu ? 1 : 0)
            .scaleEffect(showMenu ? 1 : 0.3)
            .animation(springAnimation, value: showMenu)
            
            Button {
                showMenu.toggle()
            } label: {
                Image(.comAddButton)
                    .resizable()
                    .frame(width: 62, height: 62)
                    .shadow(color: .black.opacity(0.25), radius: 5, x: 0, y: 0)
            }
            .rotationEffect(.degrees(showMenu ? 45 : 0))
            .animation(.easeInOut(duration: 0.3), value: showMenu)
        }
        .frame(width: 80, height: 80)
        .buttonStyle(.plain)
    }
}
