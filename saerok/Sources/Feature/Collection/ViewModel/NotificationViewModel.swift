//
//  NotificationViewModel.swift
//  saerok
//
//  Created by HanSeung on 8/14/25.
//

import Foundation

extension NotificationView {
    @Observable
    final class ViewModel: ObservableObject {
        private(set) var notificationItems: [Local.NotificationItem]
        private(set) var error: Error?

        private let interactor: UserInteractor
        
        init(interactor: UserInteractor) {
            self.notificationItems = []
            self.interactor = interactor
        }
        
        func loadNotifications() async {
            do {
                notificationItems = try await interactor.fetchNotifications()
            } catch {
                self.error = error
            }
        }
        
        func readNotification(_ item: Local.NotificationItem) {
            Task {
                do {
                    try await interactor.readNotification(item.notificationId)
                    if let index = notificationItems.firstIndex(where: { $0.notificationId == item.notificationId }) {
                        notificationItems[index].isRead = true
                    }
                } catch {
                    self.error = error
                }
                
            }
        }
        
        func deleteNotification(_ item: Local.NotificationItem) {
            Task {
                do {
                    try await interactor.deleteNotification(item.notificationId)
                    if let index = notificationItems.firstIndex(where: { $0.notificationId == item.notificationId }) {
                        notificationItems.remove(at: index)
                    }
                } catch {
                    self.error = error
                }
            }
        }
        
        func readAllNotification() {
            Task {
                try? await interactor.readAllNotification()
                notificationItems = notificationItems.map { item in
                    var new = item
                    new.isRead = true
                    return new
                }
            }
        }
        
        func deleteAllNotification() {
            Task {
                try await interactor.deleteAllNotification()
                notificationItems.removeAll()
            }
        }
    }
}
