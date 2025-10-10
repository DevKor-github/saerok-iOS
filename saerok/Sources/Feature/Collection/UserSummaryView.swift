//
//  UserSummaryView.swift
//  saerok
//
//  Created by HanSeung on 10/10/25.
//


import SwiftUI

struct UserSummaryView: View {
    @Environment(\.injected) private var injected: DIContainer
    private var interactor: UserInteractor { injected.interactors.user }
    
    @Binding var path: NavigationPath
    let userID: Int

    @State private var summaryState: Loadable<Void> = .notRequested
    @State private var user: Local.UserProfileSummary?
    
    var body: some View {
        content
            .regainSwipeBack()
            .onAppear {
                $summaryState.load {
                    do {
                        user = try await interactor.fetchUserSummary(userID: userID)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
    }
    
    @ViewBuilder
    private var content: some View {
        switch summaryState {
        case .notRequested: loadingView
        case .isLoading: loadingView
        case .loaded: loadedView
        case .failed: loadingView
        }
    }
}

private extension UserSummaryView {
    private var loadingView: some View {
        Text("로딩중")
    }
    
    @ViewBuilder
    private var loadedView: some View {
        ZStack(alignment: .topLeading) {
            ScrollView(showsIndicators: true) {
                Color.clear.frame(height: 70)
                UserInfoView(type: .other, user: user?.userSummary ?? .init(), joinedDate: user?.joinedDate ?? .now)
                    .padding(.leading, 15)
                StaggeredGrid(
                    items: user?.collections.reversed() ?? [],
                    columns: 2,
                    header: { countView }
                ) { bird in
                    CollectionItemView(
                        bird: bird,
                        tapped: {
                            injected
                                .appState[\.routing.collectionView.collectionID] = bird.id
                        })
                }
                .padding(.horizontal, 9)
            }
            navigationBar
        }
    }
    
    private var navigationBar: some View {
        NavigationBar(
            leading: {
                Button {
                    path.removeLast()
                } label: {
                    Image.SRIconSet.chevronLeft
                        .frame(.defaultIconSize)
                }
                .buttonStyle(.borderedIcon)
            },
            backgroundColor: .clear
        )
    }
    
    private var countView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            Text("\(user?.collectionCount ?? 0)")
                .font(.SRFontSet.heavy)
                .fontWeight(.semibold)
                .foregroundStyle(.splash)
            Text("종의 새가 새록에 담겨있어요")
                .font(.SRFontSet.caption1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundColor(.clear)
        .frame(height: 82)
        .background(Color.srWhite)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .inset(by: 0.5)
                .stroke(.splash, lineWidth: 1)
        )
    }
}

private extension UserSummaryView {
    
}
