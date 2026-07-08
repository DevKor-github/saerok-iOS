//
//  CommunityDetailView.swift
//  saerok
//
//  Created by HanSeung on 9/24/25.
//

import SwiftUI

struct CommunityDetailView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var viewModel: ViewModel
    @State private var showLoginPopup: Bool = false

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        content
            .task { await viewModel.loadInitialIfNeeded() }
            .regainSwipeBack()
    }

    private var content: some View {
        VStack(spacing: 0) {
            navigationBar
            Divider()
                .frame(height: 1)
                .foregroundStyle(.srGray)
            itemList
        }
        .overlay(alignment: .bottomTrailing) {
            collectionAddButton
                .padding(.trailing, 23)
        }
        .srPopup(
            isPresented: $showLoginPopup,
            config: showLoginPopup ? loginPopupConfig : nil
        )
    }

    private var collectionAddButton: some View {
        Button {
            if viewModel.isGuestMode {
                showLoginPopup = true
            } else {
                coordinator.push(CommunityView.Route.addCollection)
            }
        } label: {
            Image(viewModel.isGuestMode ? .floatingButtonInactive : .floatingButton)
                .resizable()
                .srStyled(.floatingButton())
        }
    }

    private var loginPopupConfig: PopupConfig {
        PopupConfig(
            title: "로그인이 필요한 기능이에요",
            message: "로그인하고 더 많은 기능을 사용해보세요!",
            buttons: .double(
                .init(
                    title: "취소",
                    style: .bordered,
                    action: {
                        showLoginPopup = false
                    }
                ),
                .init(
                    title: "로그인",
                    style: .confirm,
                    action: {
                        showLoginPopup = false
                        viewModel.initLoginStatus()
                    }
                )
            )
        )
    }

    private var navigationBar: some View {
        NavigationBar(
            center: {
                barIcon
                Text(viewModel.type.title)
                    .font(.SRFontSet.subtitle2)
            },
            leading: {
                Button {
                    coordinator.pop()
                } label: {
                    Image.SRIconSet.chevronLeft.frame(.default)
                }
                .srStyled(.borderedIconButton)
            }
        )
    }

    @ViewBuilder
    private var barIcon: some View {
        switch viewModel.type {
        case .recent:
            barIconStyle(icon: .commentCommunity, background: .accent)
        case .popular:
            barIconStyle(icon: .fire, background: .fire)
        case .suggestion:
            barIconStyle(icon: .unknown, background: .pointtext)
        default:
            EmptyView()
        }
    }

    private func barIconStyle(icon: Image.SRIconSet, background: Color) -> some View {
        icon
            .frame(.default, tintColor: icon == .unknown ? .srWhite : nil)
            .padding(4)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var itemList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(viewModel.items.enumerated()), id: \.element.id) { index, item in
                    Button {
                        coordinator.push(CommunityView.Route.detailFromCommunityList(id: item.id, type: viewModel.type))
                    } label: {
                        CommunityCell(item: item, type: viewModel.type)
                    }
                    .buttonStyle(.plain)
                    .onAppear {
                        if index == viewModel.items.count - 1 {
                            Task { await viewModel.loadMore() }
                        }
                    }
                }

                if viewModel.isLoading {
                    ProgressView().padding()
                }
            }
        }
    }
}
