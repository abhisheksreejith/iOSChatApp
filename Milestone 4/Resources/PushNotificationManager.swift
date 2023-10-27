//
//  File.swift
//  Milestone 4
//
//  Created by Abhishek-Sreejith on 14/10/23.
//
import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import FirebaseMessaging
import UIKit
import UserNotifications
class PushNotificationManager: NSObject, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    let userID: String
    init(userID: String) {
        self.userID = userID
        super.init()
    }
    func registerForPushNotification() {
        if #available(iOS 11.0, *) {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
            UNUserNotificationCenter.current().delegate = self
            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
        updateFirestorePushTokenIfNeeded()
    }
    func updateFirestorePushTokenIfNeeded() {
        if let token  = Messaging.messaging().fcmToken {
            let userRef = Firestore.firestore().collection("users").document(userID)
            userRef.setData(["fcmToken": token], merge: true)
        }
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        updateFirestorePushTokenIfNeeded()
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo
        // print(notification.request.content.userInfo)
        Messaging.messaging().appDidReceiveMessage(userInfo)
        return [.alert, .sound, .badge]
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        navigateToMessageViewController(userInfo["user"] as! String)
    }
    func navigateToMessageViewController(_ userId: String) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let messageVC = storyBoard.instantiateViewController(withIdentifier: "MessageViewController") as! MessageViewController
        messageVC.user2UID = userId
        if let topViewController = UIApplication.topViewController() {
            topViewController.navigationController?.pushViewController(messageVC, animated: true)
        }
    }
}
extension UIApplication {
    // Helper function to get the top view controller
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
