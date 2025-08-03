import Foundation
import FirebaseMessaging
import UserNotifications
import UIKit

class PushNotificationManager: NSObject {
    static let shared = PushNotificationManager()
    
    func configurePush(application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self

        requestAuthorization()
        application.registerForRemoteNotifications()
    }

    private func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
            print("🟢 알림 권한: \(granted), 에러: \(String(describing: error))")
        }
    }
    
    func setAPNSToken(_ token: Data) {
        Messaging.messaging().apnsToken = token
    }
}