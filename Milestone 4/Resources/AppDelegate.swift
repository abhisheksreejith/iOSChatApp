//
//  AppDelegate.swift
//  Milestone 4
//
//  Created by Abhishek-Sreejith on 23/09/23.
//

import UIKit
import FirebaseCore
import FirebaseMessaging
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn
import FBSDKCoreKit
import UserNotifications
import IQKeyboardManager
import LocalAuthentication
// ...
@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        let userDefaults = UserDefaults.standard
        IQKeyboardManager.shared().isEnabled = true
        // UNUserNotificationCenter.current().delegate = self
        let targetLang = UserDefaults.standard.string(forKey: "selectedLanguage")
        Bundle.setLanguage((targetLang != nil) ?targetLang! : "en")
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
//        if let userId = Auth.auth().currentUser?.uid as? String {
//            let pushManager = PushNotificationManager(userID: userId)
//            pushManager.registerForPushNotification()
//        }
       // UIApplication.shared.registerForRemoteNotifications()
        if userDefaults.bool(forKey: "loggedIn") {
            if userDefaults.bool(forKey: "BiometricsEnabled") {
                authenticateWithBiometrics()
            } else {
                DispatchQueue.main.async {
                    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                    let tabVC = storyBoard.instantiateViewController(withIdentifier: "TabViewController") as! TabViewController
                    if let topViewController = UIApplication.topViewController() {
                        topViewController.navigationController?.pushViewController(tabVC, animated: true)
                    }
                }
            }
        }
        return true
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return ApplicationDelegate.shared.application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                      annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppEvents.activateApp()
    }
    func authenticateWithBiometrics() {
        let context = LAContext()
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Authenticating using biometrics") { success, evalError in
            DispatchQueue.main.async {
                if success {
                    print("Biometric authentication succeeded")
                    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                    let tabVC = storyBoard.instantiateViewController(withIdentifier: "TabViewController") as! TabViewController
                    if let topViewController = UIApplication.topViewController() {
                        topViewController.navigationController?.pushViewController(tabVC, animated: true)
                    }
                } else {
                    if let evalError = evalError as? LAError {
                        switch evalError.code {
                        case .userFallback:
                            print("User tapped use passcode")
                        default:
                            print("Biometrics authentication failed: \(evalError.localizedDescription)")
                            exit(0)
                        }
                    }
                }
            }
        }
    }
}
