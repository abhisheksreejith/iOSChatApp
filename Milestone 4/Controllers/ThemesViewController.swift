//
//  ThemesViewController.swift
//  Milestone 4
//
//  Created by Abhishek-Sreejith on 09/10/23.
//
import UIKit
class ThemesViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var systemDefaultImage: UIImageView!
    @IBOutlet weak var darkImage: UIImageView!
    @IBOutlet weak var lightImage: UIImageView!
    let appDelegate = UIApplication.shared.windows.first
    let userDefaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.layer.cornerRadius = 12
        switch userDefaults.string(forKey: "theme") {
        case "none":
            systemDefaultImage.image = UIImage(named: "selected-radio-button")
            darkImage.image = UIImage(named: "unselected-radio-button")
            lightImage.image = UIImage(named: "unselected-radio-button")
        case "dark":
            systemDefaultImage.image = UIImage(named: "unselected-radio-button")
            darkImage.image = UIImage(named: "selected-radio-button")
            lightImage.image = UIImage(named: "unselected-radio-button")
        case "light":
            systemDefaultImage.image = UIImage(named: "unselected-radio-button")
            darkImage.image = UIImage(named: "unselected-radio-button")
            lightImage.image = UIImage(named: "selected-radio-button")
        default:
            print("Error")
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    @IBAction func systemDefaultButtonPressed(_ sender: Any) {
        appDelegate?.overrideUserInterfaceStyle = .unspecified
        userDefaults.set("none", forKey: "theme")
        systemDefaultImage.image = UIImage(named: "selected-radio-button")
        darkImage.image = UIImage(named: "unselected-radio-button")
        lightImage.image = UIImage(named: "unselected-radio-button")
    }
    @IBAction func darkButtonPressed(_ sender: Any) {
        appDelegate?.overrideUserInterfaceStyle = .dark
        userDefaults.set("dark", forKey: "theme")
        systemDefaultImage.image = UIImage(named: "unselected-radio-button")
        darkImage.image = UIImage(named: "selected-radio-button")
        lightImage.image = UIImage(named: "unselected-radio-button")
    }
    @IBAction func lightButtonPressed(_ sender: Any) {
        appDelegate?.overrideUserInterfaceStyle = .light
        userDefaults.set("light", forKey: "theme")
        systemDefaultImage.image = UIImage(named: "unselected-radio-button")
        darkImage.image = UIImage(named: "unselected-radio-button")
        lightImage.image = UIImage(named: "selected-radio-button")
    }
}
