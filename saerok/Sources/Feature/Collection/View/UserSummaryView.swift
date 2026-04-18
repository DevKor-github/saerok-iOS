//
//  UserSummaryView.swift
//  saerok
//
//  Created by HanSeung on 10/10/25.
//

import SwiftUI

struct UserSummaryView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        content
            .regainSwipeBack()
            .task { await viewModel.loadSummary() }
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.summaryState {
        case .notRequested: loadingView
        case .loading: loadingView
        case .success: loadedView
        case .failure: loadingView
        }
    }
}

private extension UserSummaryView {
    private var loadingView: some View {
        ProgressView()
            .progressViewStyle(.circular)
    }
    
    @ViewBuilder
    private var loadedView: some View {
        ZStack(alignment: .topLeading) {
            ScrollView(showsIndicators: true) {
                Color.clear
                    .frame(height: 70)
                
                UserInfoView(
                    type: .other,
                    user: viewModel.summaryState.value?.userSummary ?? .init(),
                    joinedDate: viewModel.summaryState.value?.joinedDate ?? .now,
                    onTap: {}
                )
                .padding(.leading, 15)
                
                StaggeredGrid(
                    items: viewModel.summaryState.value?.collections.reversed() ?? [],
                    columns: 2,
                    header: { countView }
                ) { bird in
                    CollectionItemView(bird) {
                        coordinator.push(CommunityView.Route.detailFromProfile(id: bird.id))
                    }
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
                    coordinator.pop()
                } label: {
                    Image.SRIconSet.chevronLeft
                        .frame(.defaultIconSize)
                }
                .srStyled(.borderedIconButton)
            },
            backgroundColor: .clear
        )
    }
    
    private var countView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\(viewModel.summaryState.value?.collectionCount ?? 0)")
                .font(.SRFontSet.heavy)
                .fontWeight(.semibold)
                .foregroundStyle(.splash)
            Text("마리의 새가 기록됐어요.")
                .font(.SRFontSet.caption1)
                .foregroundStyle(.black)
        }
        .padding(.horizontal, 19)
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
        .fixedSize(horizontal: false, vertical: true)
    }
}
