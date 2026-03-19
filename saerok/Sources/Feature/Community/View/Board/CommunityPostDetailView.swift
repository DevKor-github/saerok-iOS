//
//  CommunityPostDetailView.swift
//  saerok
//
//  Created by Codex on 3/13/26.
//

import SwiftUI

struct CommunityPostDetailView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var viewModel: ViewModel
    @State private var showToast: Bool = false
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            Divider()
                .frame(height: 1)
                .foregroundStyle(.srGray)
            content
        }
        .background(Color.srWhite)
        .srToast(isPresented: $showToast, type: .success, message: "게시글을 올렸어요.")
        .regainSwipeBack()
        .task {
            try? await Task.sleep(for: .seconds(1))
            showToast.toggle()
        }
    }
}

private extension CommunityPostDetailView {
    var navigationBar: some View {
        NavigationBar(
            center: {
                Text("자유게시판")
                    .font(.SRFontSet.subtitle2)
            },
            leading: {
                Button {
                    coordinator.pop()
                } label: {
                    Image.SRIconSet.chevronLeft
                        .frame(.defaultIconSize)
                }
                .srStyled(.borderedIconButton)
            }
        )
    }
    
    var content: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                postSection
                commentSection
                Color.clear.frame(height: 40)
            }
            .padding(.top, 16)
        }
    }
    
    var postSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            CommunityPostUserSection(
                user: viewModel.post.author,
                createdAt: viewModel.post.createdAt,
                commentCount: viewModel.post.commentCount,
                showsCommentCount: false
            )
            
            Text(viewModel.post.content.allowLineBreaking())
                .font(.SRFontSet.body4_2)
                .lineSpacing(10)
        }
        .padding(.horizontal, 24)
    }
    
    var commentSection: some View {
        CommunityCommentSection(
            comments: viewModel.comments,
            postUserId: viewModel.post.author.userId,
            isMyPost: viewModel.isMyPost
        )
    }
}

#if DEBUG
#Preview {
    CommunityPostDetailView(
        viewModel: .init(
            post: CommunityDetailView.mockPosts[0],
            comments: CommunityPostDetailView.ViewModel.mockComments
        )
    )
}
#endif

import SwiftUI

struct SRToastModifier: ViewModifier {
    enum ToastType {
        case success
        case failure
        case normal
        
        var image: Image? {
            switch self {
            case .success:
                return Image(.toastSuccess)
            case .failure:
                return Image(.toastFailure)
            case .normal:
                return nil
            }
        }
        
        var color: Color {
            switch self {
            case .success: .splash
            case .failure: .iconRed
            case .normal: .srGray
            }
        }
        
        var strokeColor: Color {
            switch self {
            case .success: .accent
            case .failure: .fire
            case .normal: .srGray
            }
        }
    }
    
    @Binding var isPresented: Bool
    
    let type: ToastType
    let message: String
    let duration: TimeInterval
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            VStack {
                Spacer()
                
                if isPresented {
                    toastView
                        .padding(.bottom, 110)
                        .transition(
                            .move(edge: .bottom)
                            .combined(with: .opacity)
                        )
                        .task {
                            try? await Task.sleep(for: .seconds(duration))
                            guard isPresented else { return }
                            
                            withAnimation(.easeInOut(duration: 0.25)) {
                                isPresented = false
                            }
                        }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(edges: .bottom)
            .animation(.easeInOut(duration: 0.25), value: isPresented)
        }
    }
    
    private var toastView: some View {
        HStack(alignment: .center, spacing: 7) {
            if let image = type.image {
                image
                    .resizable()
                    .foregroundStyle(.srWhite)
                    .padding(2)
                    .frame(width: 25, height: 25, alignment: .center)
                    .cornerRadius(8)
            } else {
                Color.clear.frame(width: 1, height: 10)
            }
            
            Text(message)
                .font(.SRFontSet.body2)
                .multilineTextAlignment(.center)
                .frame(height: 28)
            
            Image(systemName: "xmark")
                .resizable()
                .frame(width: 10, height: 10)
                .foregroundStyle(.srGray)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isPresented = false
                    }
                }
        }
        .padding(.leading, 6)
        .padding(.trailing, 13)
        .padding(.vertical, 5)
        .background(
            Color.white.opacity(0.8)
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .inset(by: 0.5)
                .stroke(type.strokeColor, lineWidth: 1)
        )
    }
}

extension View {
    func srToast(
        isPresented: Binding<Bool>,
        type: SRToastModifier.ToastType,
        message: String,
        duration: TimeInterval = 3.0
    ) -> some View {
        modifier(
            SRToastModifier(
                isPresented: isPresented,
                type: type,
                message: message,
                duration: duration
            )
        )
    }
}
