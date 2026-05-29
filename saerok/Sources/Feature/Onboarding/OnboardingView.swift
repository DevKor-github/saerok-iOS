//
//  Collection.swift
//  saerok
//
//  Created by HanSeung on 10/14/25.
//

import SwiftUI

struct OnboardingView: View {
    let type: OnboardingType
    let onSkip: () -> Void
    
    @State private var currentIndex = 0
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            onboardingCardTab
            
            Button(action: onSkip) {
                Image.SRIconSet.delete
                    .frame(.default, tintColor: .srGray)
            }
            .padding(12)
            
            Group {
                indicator
                    .offset(y: 535)
                
                skipButton
                    .offset(y: 568)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
        }
        .frame(width: 344, height: 557)
    }
    
    @ViewBuilder
    private var onboardingCardTab: some View {
        TabView(selection: $currentIndex) {
            ForEach(type.pages.indices, id: \.self) { index in
                let page = type.pages[index]
                onboardingCard(page, index: index)
                    .tag(index)
            }
        }
        .cornerRadius(20)
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
    
    private func onboardingCard(_ page: OnboardingPage, index: Int) -> some View {
        ZStack(alignment: .bottom) {
            ZStack {
                Color.pointLight
                Image(page.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 238)
                    .shadow(color: .black.opacity(0.25), radius: 15)
                    .offset(y: page.imageYOffset)
            }
            description(page)
        }
        .cornerRadius(20, corners: corners(for: index))
    }
    
    private func description(_ page: OnboardingPage) -> some View {
        VStack(spacing: 0) {
            Text(page.tabName)
                .font(.SRFontSet.body0)
                .foregroundStyle(.srWhite)
                .padding(.horizontal, 3)
                .padding(.vertical, 1)
                .background(Color.splash)
                .cornerRadius(7)
                .padding(.bottom, 11)
                .padding(.top, 14)
            
            Text(page.title)
                .font(.SRFontSet.headline2_3)
                .multilineTextAlignment(.center)
                .padding(.bottom, 8)
            
            Text(page.description)
                .font(.SRFontSet.body1)
                .foregroundColor(.srGray)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(height: 167)
        .frame(maxWidth: .infinity)
        .background(Color.srWhite)
    }
    
    private var indicator: some View {
        HStack(spacing: 5) {
            ForEach(type.pages.indices, id: \.self) { index in
                if index == currentIndex {
                    Capsule()
                        .fill(Color.splash)
                        .frame(width: 14, height: 6)
                        .transition(.slide.combined(with: .opacity))
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: 6, height: 6)
                        .transition(.slide.combined(with: .opacity))
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: currentIndex)
        .padding(.bottom, 16)
    }
    
    private var skipButton: some View {
        Button(action: onSkip) {
            ZStack {
                if currentIndex == type.pages.count - 1 {
                    Text("\(type.rawValue) 시작하기")
                        .frame(maxWidth: .infinity)
                        .font(.SRFontSet.button1_2)
                        .padding(.vertical, 16)
                        .background(Color.splash)
                        .cornerRadius(20)
                        .foregroundColor(.srWhite)
                        .transition(.asymmetric(
                            insertion: .opacity,
                            removal: .opacity
                        ))
                } else {
                    Text("건너뛰기")
                        .font(.SRFontSet.body4_2)
                        .foregroundColor(.whiteGray)
                        .transition(.asymmetric(
                            insertion: .opacity,
                            removal: .opacity
                        ))
                }
            }
            .animation(.easeInOut(duration: 0.2), value: currentIndex)
        }
        .buttonStyle(.plain)
    }
    
    private func corners(for index: Int) -> UIRectCorner {
        if index == 0 {
            return [.topLeft, .bottomLeft]
        } else if index == type.pages.count - 1 {
            return [.topRight, .bottomRight]
        } else {
            return []
        }
    }
}

struct OnboardingPage: Identifiable {
    let id = UUID()
    let tabName: String
    let title: String
    let description: String
    let imageName: ImageResource
    let imageYOffset: CGFloat
}

enum OnboardingType: String, CaseIterable, Identifiable {
    case saerok = "새록"
    case fieldGuide = "도감"
    case map = "지도"
    case nest = "둥지"
    case profile = "프로필"
    
    var id: String { rawValue }
    
    /// 각 탭별 온보딩 페이지들
    var pages: [OnboardingPage] {
        switch self {
        case .saerok:
            return [
                .init(tabName: rawValue, title: "탐조의 순간을 담았다면",
                      description: "종추 버튼을 눌러 손쉽게 새록을 작성해요.",
                      imageName: .onboarding11, imageYOffset: 37),
                .init(tabName: rawValue, title: "발견한 새의 이름을 모른다면",
                      description: "새록을 작성할 때 체크해두면\n자동으로 동정 요청이 완료돼요.",
                      imageName: .onboarding12, imageYOffset: 37),
                .init(tabName: rawValue, title: "새 이름을 알려주세요!",
                      description: "이름이 등록되지 않은 새록에는\n노란색 버튼이 보여요.",
                      imageName: .onboarding13, imageYOffset: 37),
                .init(tabName: rawValue, title: "새 이름을 알려주세요!",
                      description: "동정의견 버튼을 눌러\n나의 의견을 올릴 수 있어요.",
                      imageName: .onboarding14, imageYOffset: -42),
                .init(tabName: rawValue, title: "나의 새록 공유하기",
                      description: "주변 사람들에게 나의 탐조일지를 공유할 수 있어요.",
                      imageName: .onboarding15, imageYOffset: -116)
            ]
            
        case .fieldGuide:
            return [
                .init(tabName: rawValue, title: "좋아하는 새 북마크하기",
                      description: "나만의 도감을 만들어보세요!",
                      imageName: .onboarding21, imageYOffset: 37),
                .init(tabName: rawValue, title: "특징으로 필터링하기",
                      description: "알고 싶은 새의 특징을 활용해 찾아볼 수 있어요.",
                      imageName: .onboarding22, imageYOffset: 37)
            ]
            
        case .map:
            return [
                .init(tabName: rawValue, title: "지도 하단의 토글 버튼으로",
                      description: "내 새록만 보거나,\n다른 사람들의 새록도 같이 볼 수 있어요.",
                      imageName: .onboarding31, imageYOffset: -108),
                .init(tabName: rawValue, title: "장소를 검색하고",
                      description: "주변에서 어떤 새들이 발견되고 있는지 둘러보세요.",
                      imageName: .onboarding32, imageYOffset: 37),
                .init(tabName: rawValue, title: "화면을 위로 밀어올리면",
                      description: "주변에서 발견된 새들을 한 눈에 볼 수 있어요.",
                      imageName: .onboarding33, imageYOffset: 37)
            ]
            
        case .nest:
            return [
                .init(tabName: rawValue, title: "탐조를 위한 커뮤니티",
                      description: "다양한 새록을 보고,\n검색을 통해 원하는 새를 찾아보세요!",
                      imageName: .onboarding41, imageYOffset: 37)
            ]
            
        case .profile:
            return []
        }
    }
}

extension OnboardingType {
    var userDefaultsKey: String {
        "hasSeenOnboarding_\(rawValue)"
    }
}

#Preview {
    OnboardingView(type: .map, onSkip: {})
}
