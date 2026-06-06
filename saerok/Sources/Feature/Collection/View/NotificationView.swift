//
//  NotificationView.swift
//  saerok
//
//  Created by HanSeung on 8/14/25.
//

import SwiftUI

struct NotificationView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var viewModel: ViewModel
    @State private var showDeleteAdminConfirm = false

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    private var adminItems: [Local.Notification] {
        viewModel.items.filter { $0.type == .adminMessage }
    }
    private var regularItems: [Local.Notification] {
        viewModel.items.filter { $0.type != .adminMessage }
    }
    private var hasAdminMessages: Bool { !adminItems.isEmpty }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            navigationBar
            toggleSection
            Spacer()
        }
        .regainSwipeBack()
        .task { await viewModel.loadNotifications() }
    }

    private var toggleSection: some View {
        List {
            if hasAdminMessages {
                Section {
                    ForEach(adminItems, id: \.id) { item in
                        NotificationCell(
                            item: item,
                            onTap: { handleTap(item) }
                        )
                        .id("\(item.id)")
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 3.5, leading: 9, bottom: 3.5, trailing: 9))
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                viewModel.deleteNotification(item)
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                    }
                } header: {
                    adminSectionHeader
                        .listRowInsets(.init())
                }
                .listSectionSeparator(.hidden)

                if !regularItems.isEmpty {
                    Section {
                        ForEach(regularItems, id: \.id) { item in
                            regularCell(for: item)
                        }
                    } header: {
                        saerokSectionHeader
                            .listRowInsets(.init())
                    }
                    .listSectionSeparator(.hidden)
                }
            } else {
                ForEach(viewModel.items, id: \.id) { item in
                    regularCell(for: item)
                }
            }
        }
        .listRowSpacing(0)
        .listStyle(.plain)
        .listSectionSpacing(0)
    }

    @ViewBuilder
    private func regularCell(for item: Local.Notification) -> some View {
        NotificationCell(item: item, onTap: { handleTap(item) })
            .listRowSeparator(.hidden)
            .listRowInsets(.init(top: 3.5, leading: 9, bottom: 3.5, trailing: 9))
            .listRowBackground(Color.clear)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                    viewModel.deleteNotification(item)
                } label: {
                    Image(systemName: "trash")
                }
            }
    }

    private var adminSectionHeader: some View {
        HStack(spacing: 0) {
            VStack {
                Spacer()
                Text("운영팀")
                    .font(.SRFontSet.body4_3)
                    .foregroundStyle(Color.black)
                    .padding(.leading, 7)
            }
            
            Spacer()
            Button {
                if showDeleteAdminConfirm {
                    viewModel.deleteAdminMessages()
                    withAnimation(.easeInOut(duration: 0.2)) { showDeleteAdminConfirm = false }
                } else {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { showDeleteAdminConfirm = true }
                }
            } label: {
                if showDeleteAdminConfirm {
                    Text("지우기")
                        .font(.SRFontSet.body2_3)
                        .foregroundStyle(Color.srGray)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 11)
                        .transition(.scale(scale: 0.8).combined(with: .opacity))
                } else {
                    Image.SRIconSet.xmark
                        .frame(.custom(width: 11, height: 10))
                        .foregroundStyle(Color.srGray)
                        .padding(8)
                        .transition(.scale(scale: 0.8).combined(with: .opacity))
                }
            }
            .background(Color.srLightGray)
            .clipShape(RoundedRectangle(cornerRadius: .greatestFiniteMagnitude))
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showDeleteAdminConfirm)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 6)
        .background(Color.clear)
        .textCase(nil)
    }

    private var saerokSectionHeader: some View {
        HStack {
            VStack {
                Spacer()
                Text("새록")
                    .font(.SRFontSet.body4_3)
                    .foregroundStyle(Color.black)
                    .padding(.leading, 7)
            }
            
            Spacer()
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 6)
        .background(Color.clear)
        .textCase(nil)
    }

    private func handleTap(_ item: Local.Notification) {
        guard item.type != .adminMessage else { return }
        if case .saerok(let payload) = item.payload {
            coordinator.push(CollectionRoute.collectionDetailFromNotiCenter(payload.collectionId))
            viewModel.readNotification(item)
        } else if case .freeBoard(let payload) = item.payload {
            viewModel.readNotification(item)
            coordinator.push(CollectionRoute.directToFreeBoardPost(payload.postId))
        } else if case .announcement(let payload) = item.payload {
            viewModel.readNotification(item)
            guard let id = payload.announcementId else { return }
            coordinator.push(CollectionRoute.directToBoardDetail(id))
        }
    }

    var navigationBar: some View {
        NavigationBar(
            center: {
                Text("알림")
                    .font(.SRFontSet.subtitle2)
            }, leading: {
                Button {
                    coordinator.pop()
                } label: {
                    Image.SRIconSet.chevronLeft
                        .frame(.default)
                }
                .srStyled(.borderedIconButton)
            }, trailing: {
                Menu {
                    Button {
                        viewModel.readAllNotification()
                    } label: {
                        Label("모두 읽음", systemImage: "envelope.open")
                    }

                    Button {
                        viewModel.deleteAllNotification()
                    } label: {
                        Label("모두 삭제", systemImage: "trash")
                    }
                } label: {
                    Image.SRIconSet.option
                        .frame(.default)
                }
            }
        )
    }
}

#Preview {
    let container = DIContainer(
        interactors: .stub,
        networkService: SRNetworkServiceImpl()
    )
    let coordinator = AppCoordinator(container: container)
    let viewModel = NotificationView.ViewModel(interactor: container.interactors.user)
    NotificationView(viewModel: viewModel)
        .environmentObject(coordinator)
}
