//
//  InteractionZone.swift
//  saerok
//
//  Created by HanSeung on 3/10/26.
//

import SwiftUI

extension CollectionDetailView {
    enum InteractionZoneVariant: String, CaseIterable {
        case a
        case b
    }
}

struct InteractionZone: View {
    let variant: CollectionDetailView.InteractionZoneVariant
    
    let collection: Local.CollectionDetail
    private var isLiked: Bool { collection.isLiked }
    private var likeCount: Int { collection.likeCount }
    private var commentCount: Int { collection.commentCount }
    
    let onLikeTap: () -> Void
    let onLikeCountTap: () -> Void
    let onCommentTap: () -> Void
    
    var body: some View {
        switch variant {
        case .a:
            layoutA
        case .b:
            layoutB
        }
    }
}

private extension InteractionZone {
    var layoutA: some View {
        HStack(spacing: 15) {
            button(
                image: isLiked ? .heartFilled : .heart,
                index: likeCount,
                onTap: onLikeTap,
                additionalTap: onLikeCountTap
            )
            Divider()
                .hidden()
                .frame(width: 1, height: 38)
                .background(.srLightGray)
            button(
                image: .comment,
                index: commentCount,
                onTap: onCommentTap
            )
        }
        .padding(.vertical, 11)
        .padding(.leading, 20)
        .padding(.trailing, 18)
        .background {
            BackdropView()
                .blur(radius: 4)
        }
        .cornerRadius(40)
        .srShadow(.black(0.07, radius: 5))
        .padding(.bottom, 6)
    }
    
    var layoutB: some View {
        VStack(spacing: 12) {
            button(
                image: isLiked ? .heartFilled : .heart,
                index: likeCount,
                onTap: onLikeTap,
                additionalTap: onLikeCountTap
            )
            Divider()
                .hidden()
                .frame(width: 38, height: 1)
                .background(.srLightGray)
            button(
                image: .comment,
                index: commentCount,
                onTap: onCommentTap
            )
        }
        .padding(.horizontal, 11)
        .padding(.top, 12)
        .padding(.bottom, 15)
        .background {
            BackdropView()
                .blur(radius: 4)
        }
        .cornerRadius(40)
        .srShadow(.black(0.07, radius: 5))
        .padding(.bottom, collection.isMine ? 80 : 6)
        .padding(.trailing, 24)
    }
    
    @ViewBuilder
    func button(
        image: Image.SRIconSet,
        index: Int,
        onTap: @escaping () -> Void,
        additionalTap: (() -> Void)? = nil
    ) -> some View {
        switch variant {
        case .a:
            interactionZoneButtonA(
                image: image,
                index: index,
                onTap: onTap,
                additionalTap: additionalTap
            )
        case .b:
            interactionZoneButtonB(
                image: image,
                index: index,
                onTap: onTap,
                additionalTap: additionalTap
            )
        }
    }
}

private extension InteractionZone {
    func interactionZoneButtonA(
        image: Image.SRIconSet,
        index: Int,
        onTap: @escaping () -> Void,
        additionalTap: (() -> Void)? = nil
    ) -> some View {
        HStack(spacing: 10) {
            image
                .frame(.large)
                .padding(.vertical, 8)
                .contentShape(Rectangle())
                .onTapGesture(perform: onTap)
            
            Text(index > 99 ? "99+" : "\(index)")
                .font(.SRFontSet.subtitle3)
                .contentShape(Rectangle())
                .onTapGesture {
                    additionalTap?() ?? onTap()
                }
        }
        .frame(height: 40)
    }
    
    func interactionZoneButtonB(
        image: Image.SRIconSet,
        index: Int,
        onTap: @escaping () -> Void,
        additionalTap: (() -> Void)? = nil
    ) -> some View {
        VStack(spacing: 0) {
            image
                .frame(.large)
                .padding(8)
                .contentShape(Rectangle())
                .onTapGesture(perform: onTap)
            
            Text(index > 99 ? "99+" : "\(index)")
                .font(.SRFontSet.subtitle3)
                .contentShape(Rectangle())
                .onTapGesture {
                    additionalTap?() ?? onTap()
                }
        }
        .frame(width: 40)
    }
}
