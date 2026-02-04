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
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
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
//            ForEach(viewModel.items, id: \.id) { item in
//                NotificationCell(item: item, onTap: {
//                    coordinator.push(CollectionRoute.collectionDetail(item.collectionId))
//                    viewModel.readNotification(item)
//                })
//                .listRowSeparator(.hidden)
//                .listRowInsets(.init(top: 3.5, leading: 9, bottom: 3.5, trailing: 9))
//                .listRowBackground(Color.clear)
//                .padding(0)
//                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
//                    Button(role: .destructive) {
//                        viewModel.deleteNotification(item)
//                    } label: {
//                        Image(systemName: "trash")
//                    }
//                }
//            }
            ForEach(viewModel.items, id: \.id) { item in
                NotificationCell(item: item) {
                    if case .saerok(let payload) = item.payload {
                        coordinator.push(CollectionRoute.collectionDetail(payload.collectionId))
                        viewModel.readNotification(item)
                    } else if case .announcement(let payload) = item.payload {
                        // TODO: - 공지사항으로 이동
//                        viewModel.readNotification(item)
                    }
                }
                .listRowSeparator(.hidden)
                .listRowInsets(.init(top: 3.5, leading: 9, bottom: 3.5, trailing: 9))
                .listRowBackground(Color.clear)
                .padding(0)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        viewModel.deleteNotification(item)
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .listRowSpacing(0)
        .listStyle(.plain)
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
                        .frame(.defaultIconSize)
                }
                .buttonStyle(.borderedIcon)
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
                        .frame(.defaultIconSize)
                }
            }
        )
    }
}


