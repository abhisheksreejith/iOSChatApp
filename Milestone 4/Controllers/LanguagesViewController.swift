//
//  LanguagesViewController.swift
//  Milestone 4
//
//  Created by Abhishek-Sreejith on 11/10/23.
//

import UIKit

class LanguagesViewController: UIViewController {
    @IBOutlet weak var englishViewContainer: UIView!
    @IBOutlet weak var hindiViewCointainer: UIView!
    @IBOutlet weak var englishImageView: UIImageView!
    @IBOutlet weak var hindiImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        englishViewContainer.layer.cornerRadius = 15
        hindiViewCointainer.layer.cornerRadius = 15
        switch UserDefaults.standard.string(forKey: "selectedLanguage") {
        case "en":
            englishImageView.image = UIImage(named: "selected-radio-button")
            hindiImageView.image = UIImage(named: "unselected-radio-button")
        case "hi":
            englishImageView.image = UIImage(named: "unselected-radio-button" )
            hindiImageView.image = UIImage(named: "selected-radio-button")
        default:
            print("No user default value")
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    @IBAction func englishButtonPressed(_ sender: Any) {
        Bundle.setLanguage("en")
        UserDefaults.standard.set("en", forKey: "selectedLanguage")
        englishImageView.image = UIImage(named: "selected-radio-button")
        hindiImageView.image = UIImage(named: "unselected-radio-button")
        performAlert()
    }
    @IBAction func hindiButtonPressed(_ sender: Any) {
        Bundle.setLanguage("hi")
        UserDefaults.standard.set("hi", forKey: "selectedLanguage")
        englishImageView.image = UIImage(named: "unselected-radio-button" )
        hindiImageView.image = UIImage(named: "selected-radio-button")
        performAlert()
    }
    func performRelaunch() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let lVC = storyBoard.instantiateViewController(withIdentifier: "LoginScreenViewController") as? LoginScreenViewController
        else {
            return
        }
        self.navigationController?.pushViewController(lVC, animated: true)
    }
    func performAlert() {
        let message = "Restart the app to take effect."
        let alert = UIAlertController(title: "Language Change",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Restart Now", style: .default, handler: { _ in
            self.performRelaunch()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in
            self.userPressedCancel()
        }))
        present(alert, animated: true, completion: nil)
    }
    func userPressedCancel() {
        switch UserDefaults.standard.string(forKey: "selectedLanguage") {
        case "en":
            Bundle.setLanguage("hi")
            UserDefaults.standard.set("hi", forKey: "selectedLanguage")
            englishImageView.image = UIImage(named: "unselected-radio-button" )
            hindiImageView.image = UIImage(named: "selected-radio-button")
        case "hi":
            Bundle.setLanguage("en")
            UserDefaults.standard.set("en", forKey: "selectedLanguage")
            englishImageView.image = UIImage(named: "selected-radio-button")
            hindiImageView.image = UIImage(named: "unselected-radio-button")
        default:
            print("Error")
        }
    }
}
extension Bundle {
    class func setLanguage(_ language: String?) {
        var onceToken: Int = 0
        if onceToken == 0 {
            object_setClass(Bundle.main, PrivateBundle.self)
        }
        onceToken = 1
        objc_setAssociatedObject(Bundle.main, &associatedLanguageBundle,
                                 (language != nil) ? Bundle(path: Bundle.main.path(forResource: language, ofType: "lproj") ?? "") : nil,
                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
private var associatedLanguageBundle: Character = "1"
class PrivateBundle: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        let bundle: Bundle? = objc_getAssociatedObject(self, &associatedLanguageBundle) as? Bundle
        return bundle != nil ? (bundle!.localizedString(forKey: key, value: value, table: tableName)) : (super.localizedString(forKey: key, value: value, table: tableName))
    }
}
