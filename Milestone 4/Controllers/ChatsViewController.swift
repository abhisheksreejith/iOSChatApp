//
//  ChatsViewController.swift
//  Milestone 4
//
//  Created by Abhishek-Sreejith on 03/10/23.
//
import UIKit
import FirebaseFirestore
import FirebaseAuth
import Lottie
class ChatsViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noSearchFoundView: UIView!
    @IBOutlet weak var noResultAnimationView: LottieAnimationView!
    var refreshControl: UIRefreshControl!
    var listener: ListenerRegistration?
    var currentUserId: String!
    // let db = Firestore.firestore()
    var recentChatUsers: [DocumentSnapshot] = []
    var sortedRecentUsers: [String: Any] = [:]
    var searchResults: [QueryDocumentSnapshot] = []
    private let chatsCollection = "chats"
    private let usersCollection = "users"
    override func viewDidLoad() {
        super.viewDidLoad()
        currentUserId = Auth.auth().currentUser!.uid
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 70
        searchBar.delegate = self
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
        fetchRecentUsers(forUserUID: Auth.auth().currentUser!.uid) { document in
            self.recentChatUsers = document
            self.tableView.reloadData()
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        noSearchFoundView.isHidden = true
        let lottieUrl = "https://lottie.host/253e21c5-b320-479a-9368-8a545d14f114/pKkBgYuz8r.json"
        setupLottieAnimation(urlString: lottieUrl)
//        ChatManager.shared.getOtherUserIDsSortedByLastMessage(currentUserUID: currentUserId) { data in
//            print("\n\n\n the sorted dat is  \(data)\n\n\n")
//        }
    }
    @objc func refresh(_ sender: Any) {
        //  your code to reload tableView
        fetchRecentUsers(forUserUID: Auth.auth().currentUser!.uid) { document in
            self.recentChatUsers = document
            self.tableView.reloadData()
        }
//        ChatManager.shared.getOtherUserIDsSortedByLastMessage(currentUserUID: currentUserId) { data in
//            print("\n\n\n the sorted dat is  \(data)\n\n\n")
//        }
        refreshControl.endRefreshing()
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
        if searchBar.isFirstResponder {
            if searchBar.text == "" {
                searchBar.resignFirstResponder()
                tableView.reloadData()
            } else {
                tableView.reloadData()
            }
        }
    }
    func setupLottieAnimation(urlString url: String) {
        guard let url  = URL(string: url) else { return }
        LottieAnimation.loadedFrom(url: url, closure: {animation in
            self.noResultAnimationView.animation = animation
            self.noResultAnimationView.contentMode = .scaleAspectFit
            self.noResultAnimationView.loopMode = .loop
            self.noResultAnimationView.play()
        }, animationCache: DefaultAnimationCache.sharedCache)
    }
    func fetchRecentUsers(forUserUID userID: String, completion: @escaping([DocumentSnapshot]) -> Void) {
        let recentChatsCollection = DatabaseCollections.databses.chatsDB
        let query = recentChatsCollection.whereField("users", arrayContains: userID)
        query.getDocuments { querySnapshot, error in
            if let error = error {
                print("Error fetching recent chats: \(error.localizedDescription)")
                completion([])
                return
            }
            if let chatDocuments = querySnapshot?.documents {
                var recentUserIDs: Set<String> = Set()
                var userDocumentData: [DocumentSnapshot] = []
                let dispatchGroup = DispatchGroup()
                for chatDocument in chatDocuments {
                    let chatData = chatDocument.data()
                    if let users = chatData["users"] as? [String] {
                        for user in users where user != userID {
                            recentUserIDs.insert(user)
                        }
                    }
                }
                let recentUsers = Array(recentUserIDs)
                for userUID in recentUsers {
                    let userRef = DatabaseCollections.databses.usersDB.document(userUID)
                    dispatchGroup.enter() // Enter the dispatch group before starting the task
                    userRef.getDocument { document, error in
                        defer {
                            dispatchGroup.leave() // Leave the dispatch group when the task is done
                        }
                        if let error = error {
                            print("Error retrieving data for user \(userUID): \(error.localizedDescription)")
                            return
                        }
                        if let document = document, document.exists {
                            userDocumentData.append(document)
                        }
                    }
                }
                dispatchGroup.notify(queue: .main) {
                    completion(userDocumentData)
                }
            } else {
                completion([])
            }
        }
    }
}
extension ChatsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchResults != [] {
            return searchResults.count
        } else {
            return recentChatUsers.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? UserViewCell
        if searchResults != [] {
            let userData = searchResults[indexPath.row].data()
            let username = userData["displayName"] as? String ?? ""
            let email = userData["email"] as? String ?? ""
            let imageUrl = userData["profilePicURL"] as? String ?? ""
            if imageUrl != ""{
                if let imageURL = URL(string: imageUrl) {
                    URLSession.shared.dataTask(with: imageURL) { data, _, _ in
                        if let data = data, let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                cell?.userImage.image = image
                            }
                        }
                    }.resume()
                }
            } else {
                cell?.userImage.image = UIImage(systemName: "person.circle.fill")
            }
            cell?.username.text = username
            cell?.chatView.text = email
            return cell!
        } else {
            // if !searchBar.isFirstResponder {
            let userData = recentChatUsers[indexPath.row].data()
            let username = userData!["displayName"] as? String ?? ""
            let email = userData!["email"] as? String ?? ""
            let imageUrl = userData!["profilePicURL"] as? String ?? ""
            if imageUrl != "" {
                if let imageURL = URL(string: imageUrl) {
                    URLSession.shared.dataTask(with: imageURL) { data, _, _ in
                        if let data = data, let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                cell?.userImage.image = image
                            }
                        }
                    }.resume()
                }
            } else {
                cell?.userImage.image = UIImage(systemName: "person.circle.fill")
            }
            cell?.username.text = username
            cell?.chatView.text = email
            return cell!
            // }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchResults != [] {
            let selectedUser = searchResults[indexPath.row]
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            guard let messageVC = storyBoard.instantiateViewController(withIdentifier: "MessageViewController") as? MessageViewController
            else {
                return
            }
            messageVC.user2UID = selectedUser.documentID
            // let userData = selectedUser.data()
            // messageVC.user2Name = userData["displayName"] as? String ?? ""
            // messageVC.user2Token = userData["fcmToken"] as? String ?? ""
            self.navigationController?.pushViewController(messageVC, animated: true)
        } else {
            let selectedUser = recentChatUsers[indexPath.row]
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            guard let messageVC = storyBoard.instantiateViewController(withIdentifier: "MessageViewController") as? MessageViewController
            else {
                return
            }
            messageVC.user2UID = selectedUser.documentID
            // let userData = selectedUser.data()
            // messageVC.user2Name = userData!["displayName"] as? String ?? ""
            // messageVC.user2Token = userData!["fcmToken"] as? String ?? ""
            self.navigationController?.pushViewController(messageVC, animated: true)
        }
    }
}
extension ChatsViewController: UISearchBarDelegate {
    func searchByUserName(username: String, completion: @escaping([QueryDocumentSnapshot]) -> Void) {
        let usersCollection = DatabaseCollections.databses.usersDB
        let query = usersCollection.whereField("displayName", isGreaterThanOrEqualTo: username).whereField("displayName", isLessThanOrEqualTo: username + "z")
        query.getDocuments { querySnapshot, error in
            if let error = error {
                print("Error searching for user: \(error.localizedDescription)")
                completion([])
                return
            }
            if let documents = querySnapshot?.documents {
                let filteredDocuments = documents.filter { document in
                    return document.documentID != Auth.auth().currentUser!.uid
                }
                completion(filteredDocuments)
            } else {
                completion([])
            }
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == ""{
            searchResults.removeAll()
            tableView.isHidden = false
            noSearchFoundView.isHidden = true
            tableView.reloadData()
        } else {
            searchByUserName(username: searchText) { documents in
                if documents == [] {
                    print("No users found")
                    self.tableView.isHidden = true
                    self.noSearchFoundView.isHidden = false
                } else {
                    self.searchResults = documents
                    self.tableView.isHidden = false
                    self.noSearchFoundView.isHidden = true
                    self.tableView.reloadData()
                }
            }
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        searchResults.removeAll()
        tableView.reloadData()
    }
}
