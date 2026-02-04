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
        private(set) var items: [Local.Notification]
        private(set) var error: Error?

        private let interactor: UserInteractor
        
        init(interactor: UserInteractor) {
            self.items = []
            self.interactor = interactor
        }
        
        func loadNotifications() async {
            do {
                items = try await interactor.fetchNotifications()
            } catch {
                self.error = error
            }
        }
        
        func readNotification(_ item: Local.Notification) {
            Task {
                do {
                    try await interactor.readNotification(item.id)
                    if let index = items.firstIndex(where: { $0.id == item.id }) {
                        items[index].isRead = true
                    }
                } catch {
                    self.error = error
                }
                
            }
        }
        
        func deleteNotification(_ item: Local.Notification) {
            Task {
                do {
                    try await interactor.deleteNotification(item.id)
                    if let index = items.firstIndex(where: { $0.id == item.id }) {
                        items.remove(at: index)
                    }
                } catch {
                    self.error = error
                }
            }
        }
        
        func readAllNotification() {
            Task {
                try? await interactor.readAllNotification()
                items = items.map { item in
                    var new = item
                    new.isRead = true
                    return new
                }
            }
        }
        
        func deleteAllNotification() {
            Task {
                try await interactor.deleteAllNotification()
                items.removeAll()
            }
        }
    }
}
