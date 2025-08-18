//
//  NotificationView.swift
//  saerok
//
//  Created by HanSeung on 8/14/25.
//


import SwiftUI

struct NotificationView: View {
    @Environment(\.injected) private var injected: DIContainer
    
    private var interactor: UserInteractor { injected.interactors.user }
    
    @Binding var path: NavigationPath
    
    @State var notificationItems: [Local.NotificationItem] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            navigationBar
            
            toggleSection
            
            Spacer()
        }
        .regainSwipeBack()
        .onAppear {
            Task { @MainActor in
                do {
                    notificationItems = try await interactor.fetchNotifications()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private var toggleSection: some View {
        List {
            ForEach($notificationItems, id: \.notificationId) { $item in
                NotificationCell(item: item, onTap: {
                    path.append(CollectionView.Route.collectionDetail(item.collectionId))
                    Task {
                        try await injected.interactors.user.readNotification(item.notificationId)
                        item.isRead = true
                    }
                })
                .listRowSeparator(.hidden)
                .listRowInsets(.init(top: 0, leading: 9, bottom: 7, trailing: 9))
                .padding(0)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        Task {
                            try? await injected.interactors.user.deleteNotification(item.notificationId)
                            if let index = notificationItems.firstIndex(where: { $0.notificationId == item.notificationId }) {
                                notificationItems.remove(at: index)
                            }
                        }
                    } label: {
                        Label("삭제", systemImage: "trash")
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
                    path.removeLast()
                } label: {
                    Image.SRIconSet.chevronLeft
                        .frame(.defaultIconSize)
                }
            }, trailing: {
                Menu {
                    Button {
                        Task {
                            try await interactor.readAllNotification()
                            for notification in $notificationItems {
                                notification.isRead.wrappedValue = true
                            }
                        }
                    } label: {
                        Label("모두 읽음", systemImage: "envelope.open")
                    }
                    
                    Button {
                        Task {
                            try await interactor.deleteAllNotification()
                            notificationItems.removeAll()
                        }
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


