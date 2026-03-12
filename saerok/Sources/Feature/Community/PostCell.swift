//
//  PostCell.swift
//  saerok
//
//  Created by HanSeung on 3/11/26.
//

import SwiftUI

#if DEBUG
#Preview {
    CommunityDetailView(viewModel: .init(type: .board, interactor: MockCommunityInteractorImpl()))
}
#endif

struct PostCell: View {
    let post: DTO.Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            user
            content
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 13)
        .overlay(alignment: .bottom) {
            divider
                .offset(y: 1)
        }
    }
    
    var user: some View {
        HStack(spacing: 5) {
            ReactiveAsyncImage(
                url: post.author.profileImageUrl,
                scale: .small,
                size: .init(width: 25, height: 25),
                downsampling: true
            )
            .srAvatarStyle()
            Text(post.author.nickname!)
                .font(.SRFontSet.body3_2)
            Text("･")
                .font(.SRFontSet.caption3)
                .foregroundStyle(.srGray)
                .padding(.horizontal, 2)
            Text(post.createdAt)
                .font(.SRFontSet.caption3)
                .foregroundStyle(.srGray)
            Spacer()
            //댓글개수
            //메뉴버튼
            if post.commentCount > 0 {
                HStack(spacing: 3) {
                    Image.SRIconSet.commentFilled
                        .frame(.defaultIconSize, tintColor: .srLightGray)
                    Text("\(post.commentCount)")
                        .font(.SRFontSet.caption1_2)
                        .foregroundStyle(.srGray)
                }
            }
        }
    }
    
    var content: some View {
        Text(post.content.allowLineBreaking())
            .font(.SRFontSet.body4_2)
            .lineSpacing(10)
            .lineLimit(4)
            .padding(.leading, 30)
    }
    
    private let divider: some View = {
        Rectangle()
            .fill(Color.srLightGray)
            .frame(height: 1)
    }()
}

extension CommunityDetailView {
    static let mockPosts: [DTO.Post] = [
        .init(id: 0, title: "안녕하세요", content: "우와. 이게 뭐죠?!?!? 자유게시판이 생겼네요. 두줄까지 ㅇㅇㅇㅇ우와. 이게 뭐죠?!?!? 자유게시판이 우와. 이게 뭐죠?!?!? 자유게시판이 생겼네요. 두줄까지 ㅇㅇㅇㅇ우와. 이게 뭐죠?!?!? 자유게시판이 겓랴젇래먀저ㅑ대러쟈맫러먀ㅐㅈ더랟머ㅐ쟈",
              author: .init(userId: 0, nickname: "닭대가리",
                            profileImageUrl: "https://search.pstatic.net/common/?src=http%3A%2F%2Fblogfiles.naver.net%2FMjAyNTAyMDdfMTM1%2FMDAxNzM4OTEwMjMwNjA3.pJimibUM_9Fldi53a-OMzdHJUnzyday_jg-wT1oKeyog.5CSnsBXe5TEoYXRIiBV-Iv8UVuGrsboRx5n62QsJx0wg.JPEG%2F2024_10_%25BF%25EC%25B8%25AE_%25C1%25D6%25BA%25AF%25C0%25C0_%25BB%25F5_01_020_%25B0%25EF%25C1%25D9%25B9%25DA%25C0%25CC.jpg&type=sc960_832"),
              likeCount: 0, commentCount: 0, isLiked: true, createdAt: "12시간 전"),

        .init(id: 1, title: "첫 글", content: "우와. 이게 뭐죠?!?!? 자유게시판이 생겼네요. 두줄까지 ㅇㅇㅇㅇ우와. 이게 뭐죠?!?!? 자유게시판이 생겼네요. ",
              author: .init(userId: 1, nickname: "코딩왕", profileImageUrl: "https://search.pstatic.net/sunny/?src=https%3A%2F%2Fpreview.clipartkorea.co.kr%2F2002%2F12%2F28%2Fihca0099.jpg&type=sc960_832"),
              likeCount: 3, commentCount: 1, isLiked: false, createdAt: "11시간 전"),

        .init(id: 2, title: "오늘 점심", content: "오늘 뭐 먹지 추천좀",
              author: .init(userId: 2, nickname: "보문동새록마스터", profileImageUrl: "https://search.pstatic.net/common/?src=http%3A%2F%2Fblogfiles.naver.net%2FMjAyMDEwMDhfMTA1%2FMDAxNjAyMTM4MzAwNDUx.eLu2gUK0m_UAeY9IeF86_pmoq-OOISbXCuO_DZEdewEg.YRKuGP_VM6fFRoYCIMRpA0mSAmBMczhDhS1SE6B2w6og.JPEG.zhouyin73%2F16650216020599040.jpg&type=sc960_832"),
              likeCount: 5, commentCount: 2, isLiked: false, createdAt: "10시간 전"),

        .init(id: 3, title: "SwiftUI 질문", content: "애니메이션 왜 끊길까",
              author: .init(userId: 3, nickname: "범내려온다", profileImageUrl: "https://search.pstatic.net/common/?src=http%3A%2F%2Fblogfiles.naver.net%2FMjAxOTAxMzFfMjc4%2FMDAxNTQ4OTAwMjY4Njk0.Dn94Isvk0YULx5MPMFMcbmXMIGsIwczoud00sAHJH1Eg.5qTE7yyk0Z8FCaaO6W3MsXPZ8VIli_X9p7O2JlWQRL8g.JPEG.malong_blog2%2Ffrp_%25B5%25BF%25B9%25B0_%25C1%25B6%25C7%25FC%25B9%25B0___%25B1%25EE%25C5%25F5%25B8%25AE_%25BB%25F5_%25C4%25B3%25B8%25AF%25C5%25CD_%25C0%25FC%25BD%25C3_%25B4%25EB%25C7%25FC_%25B8%25F0%25C7%25FC_%25C1%25A6%25C0%25DB_%252810%2529.jpg&type=sc960_832"),
              likeCount: 2, commentCount: 4, isLiked: true, createdAt: "9시간 전"),

        .init(id: 4, title: "출근", content: "오늘도 출근이다",
              author: .init(userId: 4, nickname: "매일출근직장인", profileImageUrl: "https://search.pstatic.net/common/?src=http%3A%2F%2Fblogfiles.naver.net%2F20111111_240%2Fsrchcu_1320975949240TR7uW_JPEG%2FAngry_Birds.jpg&type=sc960_832"),
              likeCount: 7, commentCount: 1, isLiked: false, createdAt: "8시간 전"),

        .init(id: 5, title: "퇴근", content: "퇴근하고 싶다",
              author: .init(userId: 5, nickname: "피곤함", profileImageUrl: "https://search.pstatic.net/common/?src=http%3A%2F%2Fshop1.phinf.naver.net%2F20240120_49%2F1705757100129Y76Em_JPEG%2F19811607007241350_1662909578.jpg&type=sc960_832"),
              likeCount: 4, commentCount: 0, isLiked: false, createdAt: "7시간 전"),

        .init(id: 6, title: "iOS", content: "SwiftUI 생각보다 재밌네",
              author: .init(userId: 6, nickname: "애플좋아", profileImageUrl: "https://search.pstatic.net/sunny/?src=https%3A%2F%2Fas2.ftcdn.net%2Fv2%2Fjpg%2F01%2F13%2F46%2F63%2F1000_F_113466343_TD3F8sffzD0x7zYyUGSwVEpF59uVgsmz.jpg&type=sc960_832"),
              likeCount: 10, commentCount: 3, isLiked: true, createdAt: "6시간 전"),

        .init(id: 7, title: "주말", content: "주말 뭐하지",
              author: .init(userId: 7, nickname: "핑크퐁", profileImageUrl: "https://search.pstatic.net/common/?src=http%3A%2F%2Fshop1.phinf.naver.net%2F20250224_131%2F1740396851447vHodp_JPEG%2F16014904913005007_801123708.jpg&type=sc960_832"),
              likeCount: 1, commentCount: 0, isLiked: false, createdAt: "5시간 전"),

        .init(id: 8, title: "질문", content: "Combine 아직도 쓰나요",
              author: .init(userId: 8, nickname: "궁금함", profileImageUrl: "https://search.pstatic.net/sunny/?src=https%3A%2F%2Fimg.mdeco.kr%2F2022-08-04%2F20220816-051.jpg&type=sc960_832"),
              likeCount: 6, commentCount: 2, isLiked: false, createdAt: "4시간 전"),

        .init(id: 9, title: "마지막 글", content: "목데이터 마지막",
              author: .init(userId: 9, nickname: "마무리", profileImageUrl: "https://search.pstatic.net/sunny/?src=https%3A%2F%2Fmedia.istockphoto.com%2Fid%2F1187814942%2Fko%2F%25EB%25B2%25A1%25ED%2584%25B0%2F%25EB%2582%2598%25EC%259D%25B4%25ED%258C%2585%25EA%25B2%258C%25EC%259D%25BC-%25EC%25A1%25B0%25EB%25A5%2598-%25EB%258F%2599%25EB%25AC%25BC-%25EB%25A7%258C%25ED%2599%2594-%25EC%25BA%2590%25EB%25A6%25AD%25ED%2584%25B0.jpg%3Fs%3D612x612%26w%3Dis%26k%3D20%26c%3D8TWAKGke2D3aJPbxqZULUgFSnhI3vXRDTolKrIHZJ50%3D&type=sc960_832"),
              likeCount: 0, commentCount: 0, isLiked: false, createdAt: "3시간 전")
    ]
}
