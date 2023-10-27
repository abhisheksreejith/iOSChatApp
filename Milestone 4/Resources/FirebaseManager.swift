//
//  FirebaseManager.swift
//  Milestone 4
//
//  Created by Abhishek-Sreejith on 17/10/23.
//
import Foundation
import FirebaseFirestore
class FirestoreManager: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var imageView: UIImage?
    var imageURL: String?
    @Published var userID: String?
    init() {
        fetchUserDetail()
    }
    func fetchUserDetail() {
        if let userID = userID {
            let docRef = DatabaseCollections.databses.usersDB.document(userID)
            docRef.getDocument { document, error in
                guard error == nil else {
                    print("Error: \(error!)")
                    return
                }
                if let document = document, document.exists {
                    let data = document.data()
                    if let data = data {
                        self.name = data["displayName"] as! String
                        self.email = data["email"] as! String
                        self.imageURL = data["profilePicURL"] as? String
                        if let imageURL = self.imageURL {
                            self.fetchUserImage(urlString: imageURL)
                        }
                    }
                }
            }
        }
    }
    func fetchUserImage(urlString: String) {
        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    self.imageView = UIImage(data: data)!
                }
            }
            task.resume()
        }
    }
}
