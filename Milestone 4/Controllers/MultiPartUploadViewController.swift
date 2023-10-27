//
//  MultiPartUploadViewController.swift
//  Milestone 4
//
//  Created by Abhishek-Sreejith on 07/10/23.
//
import UIKit
class MultiPartUploadViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    let apikey = "API key"
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    @IBAction func selectImageButtonPressed(_ sender: Any) {
        presentPhtotoPicker()
    }
    @IBAction func uploadimageButtonPressed(_ sender: Any) {
        uploadImage(fileName: "image.jpg", image: imageView.image!)
    }
}
extension MultiPartUploadViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func presentPhotoActioSheet() {
        let actionSheet = UIAlertController(title: "Profile picture",
                                            message: "How would you like to select a picture?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Choose Photo",
                                            style: .default,
                                            handler: { [weak self] _ in
            self?.presentPhtotoPicker()
        }))
        present(actionSheet, animated: true)
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
        self.imageView.image = selectedImage
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func uploadImage(fileName: String, image: UIImage) {
        let url = URL(string: "https://file.io")
        let boundary = UUID().uuidString
        let session = URLSession.shared
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Basic \(apikey)", forHTTPHeaderField: "Authorization")
        var data = Data()
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        data.append(image.pngData()!)
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        session.uploadTask(with: urlRequest, from: data, completionHandler: { responseData, _, error in
            if error == nil {
                let jsonData = try? JSONSerialization.jsonObject(with: responseData!, options: .allowFragments)
                if let json = jsonData as? [String: Any] {
                    print(json)
                }
            }
        }).resume()
    }
}
