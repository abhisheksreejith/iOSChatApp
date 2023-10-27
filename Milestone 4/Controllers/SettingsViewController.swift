//
//  SettingsViewController.swift
//  Milestone 4
//
//  Created by Abhishek-Sreejith on 30/09/23.
//
import UIKit
import FirebaseAuth
import GoogleSignIn
import FBSDKLoginKit
class SettingsViewController: UIViewController {
    @IBOutlet weak var darkMode: UIView!
    @IBOutlet weak var biometricsView: UIView!
    @IBOutlet weak var logoutView: UIView!
    @IBOutlet weak var multiPartUploadView: UIView!
    @IBOutlet weak var tncView: UIView!
    @IBOutlet weak var languagesView: UIView!
    let userDefaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        darkMode.layer.cornerRadius = 15
        biometricsView.layer.cornerRadius = 15
        logoutView.layer.cornerRadius = 15
        multiPartUploadView.layer.cornerRadius = 15
        tncView.layer.cornerRadius = 15
        languagesView.layer.cornerRadius = 15
        navigationController?.navigationBar.isHidden = false
        if Auth.auth().currentUser == nil {
            logoutView.isHidden = true
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    @IBAction func profileEditingButton(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let profileVC = storyBoard.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController
        else {
            return
        }
        profileVC.userNameField?.isEnabled = true
        profileVC.uniqueUserNameField?.isEnabled = true
        profileVC.navigationController?.navigationBar.isHidden = false
        profileVC.navbarView?.isHidden = true
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    @IBAction func themesButtonPressed(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let themesVC = storyBoard.instantiateViewController(withIdentifier: "ThemesViewController") as? ThemesViewController
        else {
            return
        }
        self.navigationController?.pushViewController(themesVC, animated: true)
    }
    @IBAction func biometricsButtonPressed(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let biometricsVC = storyBoard.instantiateViewController(withIdentifier: "BiometricsViewController") as? BiometricsViewController
        else {
            return
        }
        self.navigationController?.pushViewController(biometricsVC, animated: true)
    }
    @IBAction func tncButtonPressed(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let tncVC = storyBoard.instantiateViewController(withIdentifier: "TCViewController") as? TCViewController
        else {
            return
        }
        self.navigationController?.pushViewController(tncVC, animated: true)
    }
    @IBAction func languagesButtonPressed(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let lVC = storyBoard.instantiateViewController(withIdentifier: "LanguagesViewController") as? LanguagesViewController
        else {
            return
        }
        self.navigationController?.pushViewController(lVC, animated: true)
    }
    @IBAction func logoutButtonPressed(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let loginVC = storyBoard.instantiateViewController(withIdentifier: "LoginScreenViewController") as? LoginScreenViewController
        else {
            return
        }
        // Sign out from Google
        LoginManager().logOut()
        GIDSignIn.sharedInstance()?.signOut()
        // Sign out from Firebase
        do {
            try Auth.auth().signOut()
            print("logout successful ")
            UserDefaults.standard.set(false, forKey: "loggedIn")
            // Update screen after user successfully signed out
        } catch let error as NSError {
            print("Error signing out from Firebase: %@", error)
        }
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
    @IBAction func mutliPartUploadAction(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let tabVC = storyBoard.instantiateViewController(withIdentifier: "MultiPartUploadViewController") as? MultiPartUploadViewController
        else {
            return
        }
        self.navigationController?.pushViewController(tabVC, animated: true)
    }
}
