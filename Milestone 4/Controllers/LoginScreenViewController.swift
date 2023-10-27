import UIKit
import GoogleSignIn
import FirebaseCore
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit
import AuthenticationServices
import CryptoKit

import FirebaseFirestore
class LoginScreenViewController: UIViewController {
    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var languageButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButtonView: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var stackViewContainer: UIStackView!
    fileprivate var currentNonce: String?
    let userDefaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        languageButton.layer.cornerRadius = 2
        loginButtonView.layer.cornerRadius = 15
        activityIndicator.isHidden = true
        switch userDefaults.string(forKey: "theme") {
        case "none":
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .unspecified
        case "dark":
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
        case "light":
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
        default:
            print("Error")
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
        @IBAction func phoneButtonPressed(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let photoVC = storyBoard.instantiateViewController(withIdentifier: "PhoneNumberScreenViewContoller") as? PhoneNumberScreenViewContoller
        else {
            return
        }
        self.navigationController?.pushViewController(photoVC, animated: true)
    }
    @IBAction func googleButton(_ sender: Any) {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    @IBAction func languageButtonPressed(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let lVC = storyBoard.instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController
        else {
            return
        }
        self.navigationController?.pushViewController(lVC, animated: true)
    }
    @IBAction func loginButtonPressed(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().createUser(withEmail: email, password: password) { _, error in
                if let error = error {
                    print("\(error)")
                    if let errorCode = AuthErrorCode(rawValue: error._code) {
                        print("Error has occured \(error)")
                        print("This is error code \(errorCode.rawValue)")
                        print("\(AuthErrorCode.emailAlreadyInUse.rawValue)")
                        if errorCode == .emailAlreadyInUse {
                            self.signiin(withemail: email, withpassword: password)
                        }
                    }
                } else {
                    self.startActivityIndicator()
                    self.checkUserDataPresentInFirestore()
                }
            }
        }
    }
    func startActivityIndicator() {
        self.activityIndicator.isHidden = false
        self.stackViewContainer.isHidden = true
        self.activityIndicator.startAnimating()
        self.activityIndicator.hidesWhenStopped = true
    }
    func signiin(withemail email: String, withpassword password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error2 in
            if let error2 = error2 {
                print("Error \(error2.localizedDescription)")
            } else {
                self.startActivityIndicator()
                self.checkUserDataPresentInFirestore()
            }
        }
    }
    // MARK: - facebook authentication
    @IBAction func facebookButton(_ sender: Any) {
        let loginManger = LoginManager()
        loginManger.logIn(permissions: ["public_profile", "email"], from: self) { result, error in
            if error != nil {
                print("Facebook login failed")
            } else if result?.isCancelled == true {
                print("Facebook login was Cancellled")
            } else {
                self.startActivityIndicator()
                print("facebook login successful")
                if let token = result?.token {
                    let credentials = FacebookAuthProvider.credential(withAccessToken: token.tokenString )
                    Auth.auth().signIn(with: credentials) { _, error in
                        if  error != nil {
                            print("Firebase login failed \(String(describing: error))")
                        } else {
                            self.checkUserDataPresentInFirestore()
                        }
                    }
                }
            }
        }
    }
    @IBAction func apppleLoginButton(_ sender: Any) {
        startSignInWithAppleFlow()
    }
    func checkUserDataPresentInFirestore() {
        let userID = (Auth.auth().currentUser?.uid)!
        userDefaults.set(true, forKey: "loggedIn")
        let userDocRef = DatabaseCollections.databses.usersDB.document(userID)
        userDocRef.getDocument { document, error in
            if let error = error {
                print("Error checking userData: \(error.localizedDescription)")
                return
            }
            if let document = document, document.exists {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                guard let photoVC = storyBoard.instantiateViewController(withIdentifier: "TabViewController") as? TabViewController
                else {
                    return
                }
                photoVC.navigationItem.hidesBackButton = true
                self.stackViewContainer.isHidden = false
                self.activityIndicator.stopAnimating()
                self.navigationController?.pushViewController(photoVC, animated: true)
            } else {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                guard let profileVC = storyBoard.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController
                else {
                    return
                }
                profileVC.previouseViewController = "0"
                profileVC.navigationItem.hidesBackButton = true
                self.stackViewContainer.isHidden = false
                self.activityIndicator.stopAnimating()
                self.navigationController?.pushViewController(profileVC, animated: true)
            }
        }
    }
}
// MARK: - Google authentication
extension LoginScreenViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if user == nil {
            print("user cancelled signin")
            return
        }
        guard let authentication = user.authentication else {
            return
        }
        self.startActivityIndicator()
        print("authentication with google successful")
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (_, error) in
            if let error = error {
                print("Error occurs when authenticate with Firebase: \(error.localizedDescription)")
            } else {
                self.checkUserDataPresentInFirestore()
            }
        }
    }
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("Login failed")
    }
}
// MARK: - appleID authentication
extension LoginScreenViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    @available(iOS 13, *)
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )}
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        return String(nonce)
    }
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        return hashString
    }
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            self.startActivityIndicator()
            // Initialize a Firebase credential, including the user's full name.
            let  credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                       idToken: idTokenString, rawNonce: nonce,
                                                       accessToken: appleIDCredential.fullName as?  String)
            Auth.auth().signIn(with: credential) { (_, error) in
                if error != nil {
                    print("Firebase failed \(error!.localizedDescription)")
                    return
                }
                self.checkUserDataPresentInFirestore()
            }
        }
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
