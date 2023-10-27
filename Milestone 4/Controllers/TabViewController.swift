//
//  TabViewController.swift
//  Milestone 4
//
//  Created by Abhishek-Sreejith on 28/09/23.
//
import UIKit
import FirebaseAuth
class TabViewController: UITabBarController {
    var upperLineView: UIView!
    let spacing: CGFloat = 12
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        navigationItem.setHidesBackButton(true, animated: false)
        delegate = self
        let userId = Auth.auth().currentUser?.uid as? String
        let pushManager = PushNotificationManager(userID: userId!)
        pushManager.registerForPushNotification()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.addTabbarIndicatorView(index: 0, isFirstTime: true)
        }
        //        let userId = Auth.auth().currentUser?.uid as? String
        //        let pushManager = PushNotificationManager(userID: userId!)
        //        pushManager.registerForPushNotification()
    }
    func addTabbarIndicatorView(index: Int, isFirstTime: Bool = false) {
        guard let tabView = tabBar.items?[index].value(forKey: "view") as? UIView else {
            return
        }
        if !isFirstTime {
            upperLineView.removeFromSuperview()
        }
        upperLineView = UIView(frame: CGRect(x: tabView.frame.minX + spacing,
                                             y: tabView.frame.minY + 0.1,
                                             width: tabView.frame.size.width - spacing * 2, height: 4))
        upperLineView.backgroundColor = UIColor(named: "TabbarTint")
        tabBar.addSubview(upperLineView)
    }
}
extension TabViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        addTabbarIndicatorView(index: selectedIndex)
    }
}
