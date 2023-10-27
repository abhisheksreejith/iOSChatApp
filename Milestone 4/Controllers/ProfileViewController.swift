//
//  ProfileViewController.swift
//  Milestone 4
//
//  Created by Abhishek-Sreejith on 03/10/23.
//
import UIKit
import FirebaseAuth
import FirebaseFirestore
class ProfileViewController: UIViewController {
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var uniqueUserNameField: UITextField!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var navbarView: UIView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var cancelEditing: UIButton!
    @IBOutlet weak var editLabelView: UIView!
    var previouseViewController: String = ""
    var nameString: String = ""
    var imageURLString: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uniqueUserNameField.text = Auth.auth().currentUser?.email
        userImageView.layer.cornerRadius = userImageView.frame.width / 2
        editLabelView.layer.cornerRadius = editLabelView.frame.height / 2
        editButton.layer.cornerRadius = 12
        editLabelView.isHidden = true
        userNameField.isEnabled = false
        profileButton.isEnabled = false
        saveButton.isHidden = true
        cancelEditing.isHidden = true
        loadUserProfile()
        if previouseViewController != "" {
            whenFromLoginScreen()
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    override func viewDidAppear(_ animated: Bool) {
        loadUserProfile()
    }
    override func viewWillAppear(_ animated: Bool) {
        loadUserProfile()
    }
    @IBAction func profileChangeButton(_ sender: Any) {
        presentPhotoActioSheet()
    }
    @IBAction func settingsButtonPressed(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let settingsVC = storyBoard.instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController
        else {
            return
        }
        settingsVC.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(settingsVC, animated: true)
    }
    @IBAction func editProfilePressed(_ sender: Any) {
        editLabelView.isHidden = false
        userNameField.isEnabled = true
        profileButton.isEnabled = true
        editButton.isHidden = true
        settingsButton.isHidden = true
        saveButton.isHidden = false
        cancelEditing.isHidden = false
        headingLabel.text = NSLocalizedString("ProfileViewcontroller.Heading2", comment: "Edit Profile")
    }
    @IBAction func cancelProfileEditingPressed(_ sender: Any) {
        editLabelView.isHidden = true
        userNameField.isEnabled = false
        profileButton.isEnabled = false
        editButton.isHidden = false
        settingsButton.isHidden = false
        saveButton.isHidden = true
        headingLabel.text = NSLocalizedString("ProfileViewcontroller.Heading1", comment: "Profile")
        cancelEditing.isHidden = true
        loadUserProfile()
    }
    @IBAction func saveButtonPressed(_ sender: Any) {
        headingLabel.text = NSLocalizedString("ProfileViewcontroller.Heading1", comment: "Profile")
        imageURLString = AwsUpload.shared.imageUrl
        if let user = Auth.auth().currentUser {
            let userRef = DatabaseCollections.databses.usersDB.document(user.uid)
            if !userNameField.text!.isEmpty {
                let userData: [String: Any] = ["displayName": userNameField.text!, "email": user.email ?? "no email", "profilePicURL": imageURLString]
                userRef.setData(userData, merge: true) { error in
                    print("\(error?.localizedDescription ?? "")")
                }
            } else {
                let alert = UIAlertController(title: "Empty field", message: "Enter the Name.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                present(alert, animated: true, completion: nil)
                return

            }
        }
        editLabelView.isHidden = true
        userNameField.isEnabled = false
        profileButton.isEnabled = false
        editButton.isHidden = false
        settingsButton.isHidden = false
        saveButton.isHidden = true
        cancelEditing.isHidden = true
        if previouseViewController != "" {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            guard let settingsVC = storyBoard.instantiateViewController(withIdentifier: "TabViewController") as? TabViewController
            else {
                return
            }
            settingsVC.navigationController?.navigationBar.isHidden = false
            self.navigationController?.pushViewController(settingsVC, animated: true)
        }
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    func fetchProfileImage(imageUrl: String) {
        if let imageURL = URL(string: imageUrl) {
            URLSession.shared.dataTask(with: imageURL) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.userImageView.image = image
                    }
                }
            }.resume()
        }
    }
    func loadUserProfile() {
        if let user = Auth.auth().currentUser {
            let userRef = DatabaseCollections.databses.usersDB.document(user.uid)
            userRef.getDocument { document, error in
                if let error = error {
                    print("Error retrieving data: \(error.localizedDescription)")
                    return
                }
                if let document = document, document.exists {
                    let userData = document.data()
                    if let displayName = userData?["displayName"] as? String,
                       let email = userData?["email"] as? String, let imageURL = userData?["profilePicURL"] as? String {
                        self.userNameField.text = displayName
                        self.nameString = displayName
                        self.uniqueUserNameField.text = email
                        self.uniqueUserNameField.isEnabled = false
                        if let url = URL(string: imageURL) {
                            let request = URLRequest(url: url)
                            URLCache.shared.removeCachedResponse(for: request)
                        }
                        self.fetchProfileImage(imageUrl: imageURL)
                    } else {
                        print("User data missing")
                    }
                } else {
                    print("User document doesnt exist")
                }
            }
        }
    }
    func whenFromLoginScreen() {
        editLabelView.isHidden = false
        userNameField.isEnabled = true
        profileButton.isEnabled = true
        editButton.isHidden = true
        settingsButton.isHidden = true
        saveButton.isHidden = false
        // cancelEditing.isHidden = false
        headingLabel.text = NSLocalizedString("ProfileViewcontroller.Heading2", comment: "Edit Profile")
    }
}
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func presentPhotoActioSheet() {
        let actionSheet = UIAlertController(title: "Profile picture", message: "How would you like to select a picture?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take photo", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhtotoPicker()
        }))
        if let user = Auth.auth().currentUser {
            let userRef = DatabaseCollections.databses.usersDB.document(user.uid)
            userRef.getDocument { document, error in
                if let error = error {
                    print("Error retrieving data: \(error.localizedDescription)")
                    return
                }
                if let document = document, document.exists {
                    let userData = document.data()
                    if userData?["profilePicURL"] as? String == "" {
                    } else {
                        actionSheet.addAction(UIAlertAction(title: "Remove", style: .default, handler: { [weak self] _ in
                            self?.userImageView.image = UIImage(named: "people_fill")
                            let userData: [String: Any] = ["profilePicURL": ""]
                            userRef.setData(userData, merge: true) { error in
                                print("\(error?.localizedDescription ?? "")")
                            }
                            self?.loadUserProfile()
                        }))
                    }
                }
            }
        }
        present(actionSheet, animated: true)
    }
    func presentCamera() {
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.sourceType = .camera
        imagePickerVC.delegate = self
        imagePickerVC.allowsEditing = true
        present(imagePickerVC, animated: true)
    }
    func presentPhtotoPicker() {
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.sourceType = .photoLibrary
        imagePickerVC.delegate = self
        imagePickerVC.allowsEditing = true
        present(imagePickerVC, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        print(info)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        self.userImageView.image = selectedImage
        let imageName = "\(nameString)Profile.jpeg"
        AwsUpload.shared.uploadImage(imagaData: selectedImage, imageName: imageName)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
