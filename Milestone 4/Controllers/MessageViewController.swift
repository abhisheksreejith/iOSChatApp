//
//  MessageViewController.swift
//  Milestone 4
//
//  Created by Abhishek-Sreejith on 04/10/23.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore
import FirebaseAuth
import SwiftUI
class MessageViewController: MessagesViewController, InputBarAccessoryViewDelegate, MessagesDataSource,
                             MessagesLayoutDelegate, MessagesDisplayDelegate, MessageCellDelegate {
    var currentUser = Auth.auth().currentUser!       
    private var  docReference: DocumentReference?
    var messages: [Message] = []
    var user2UID: String?
    var currentUserImage: UIImage?
    var secondUserImage: UIImage?
    var currentUserData: [String: Any]?
    var otherUserData: [String: Any]?
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        maintainPositionOnKeyboardFrameChanged = true
        scrollsToLastItemOnKeyboardBeginsEditing = true
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBarConfiguration()
        getUserByID(forUserId: currentUser.uid) { userData in
            self.currentUserData = userData
        }
        getUserByID(forUserId: user2UID!) { userData in
            self.otherUserData = userData
        }
        loadChat()
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
        messageInputBar.inputTextView.resignFirstResponder()
    }
    @IBAction func shareButtonPressed(_ sender: Any) {
        let link = "milestone4://profile/userid=\(user2UID!)"
        let text = "Checkout this profile...."
        let image = UIImage(named: "settings")
        let myWebsite = NSURL(string: "\(link)")
        let shareAll = [text, image!, myWebsite!] as [Any]
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    func messageInputBarConfiguration() {
        messageInputBar.inputTextView.tintColor = .systemBlue
        messageInputBar.sendButton.setTitleColor(.systemTeal, for: .normal)
        messagesCollectionView.backgroundColor = UIColor(named: "MainScreenColor")
        messageInputBar.inputTextView.backgroundColor = UIColor(named: "MessageInputBarColor")
        messageInputBar.backgroundView.backgroundColor = UIColor(named: "TabbarColor")
        messageInputBar.inputTextView.layer.cornerRadius = 15
        messageInputBar.inputTextView.placeholder = "Message"
        messageInputBar.sendButton.title = ""
        messageInputBar.sendButton.setBackgroundImage(UIImage(named: "send"), for: .normal)// UIImage(systemName: "paperplane.circle.fill"), for: .normal)
        messageInputBar.sendButton.tintColor = UIColor(named: "MessageInputBarColor")
        messageInputBar.sendButton.contentMode = .scaleAspectFill
        messageInputBar.setRightStackViewWidthConstant(to: 40, animated: false)
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    func loadChat() {
        let chatsDB = DatabaseCollections.databses.chatsDB
            .whereField("users", arrayContains: Auth.auth().currentUser?.uid ?? "Not found user 1")
        chatsDB.getDocuments { chatQuerySnap, error in
            if let error = error {
                print("\(error.localizedDescription)")
                return
            } else {
                guard let queryCount = chatQuerySnap?.documents.count else { return }
                if queryCount == 0 {
                    self.createNewChat()
                } else if queryCount >= 1 {
                    for doc in chatQuerySnap!.documents {
                        let chat = Chat(dictionary: doc.data())
                        if (chat?.users.contains(self.user2UID ?? "ID not found")) == true {
                            self.docReference = doc.reference
                            doc.reference.collection("thread")
                                .order(by: "created", descending: false)
                                .addSnapshotListener(includeMetadataChanges: true) { threadQuery, error in
                                    if let error = error {
                                        print("\(error)")
                                        return
                                    } else {
                                        self.messages.removeAll()
                                        for message in threadQuery!.documents {
                                            let msg = Message(dictionary: message.data())
                                            self.messages.append(msg!)
                                        }
                                        self.messagesCollectionView.reloadData()
                                        self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: false)
                                    }
                                }
                            return
                        }
                    }
                    self.createNewChat()
                } else {
                    print("Lets hope this error never prints")
                }
            }
        }
    }
    func createNewChat() {
        let users = [self.currentUser.uid, self.user2UID]
        let data: [String: Any] = ["users": users]
        let chatsDB = DatabaseCollections.databses.chatsDB
        chatsDB.addDocument(data: data) { error in
            if let error = error {
                print("unable to create a chat: \(error.localizedDescription)")
                return
            } else {
                self.loadChat()
            }
        }
    }
    private func insertNewMessage(_ message: Message) {
        messages.append(message)
        messagesCollectionView.reloadData()
        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: false)
        }
    }
    private func save(_ message: Message) {
        let data: [String: Any] = ["content": message.content, "created": message.created,
                                   "id": message.id, "senderId": message.senderId,
                                   "senderName": message.senderName]
        print("\n\n\(message.senderId)\n\n")
        docReference?.collection("thread").addDocument(data: data, completion: {error in
            if let error = error {
                print("Error sending messages: \(error.localizedDescription)")
                return
            }
            self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: false)
        })
        let lastMessage: [String: Timestamp] = ["lastMessage": message.created]
        // let chatsDB = DatabaseCollections.databses.chatsDB
        docReference?.setData(lastMessage, merge: true) { error in
            print("\(error?.localizedDescription ?? "")")
        }
        //        docReference?.addDocument(data: data) { error in
        //            if let error = error {
        //                print("unable to create a chat: \(error.localizedDescription)")
        //                return
        //            } else {
        //                //self.loadChat()
        //            }
        //        }
    }
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let message = Message(id: UUID().uuidString, content: text,
                              created: Timestamp(),
                              senderId: currentUser.uid,
                              senderName: currentUserData!["displayName"] as! String)
        insertNewMessage(message)
        save(message)
        let sender = PushNotificationSender()
        sender.sendPushNotification(to: otherUserData!["fcmToken"] as! String,
                                    title: currentUserData!["displayName"] as! String,
                                    body: message.content,
                                    senderID: message.senderId)
        inputBar.inputTextView.text = ""
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem(at: .bottom, animated: false)
    }
    func currentSender() -> SenderType {
        return ChatUser(senderId: Auth.auth().currentUser?.uid ?? "No user signed in",
                        displayName: (Auth.auth().currentUser?.displayName ?? "Name not Found"))
    }
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        if messages.count == 0 {
            return 0
        } else {
            return messages.count
        }
    }
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        self.title = otherUserData!["displayName"] as? String ?? "Chat"
        let senderID = message.sender.senderId
        let defaultImage = Avatar(image: UIImage(named: "people_fill"), initials: "")
        avatarView.backgroundColor = .none
        avatarView.tintColor = .darkGray
        avatarView.set(avatar: defaultImage)
        if senderID == currentUser.uid {
            loadImageFromURL(url: currentUserData!["profilePicURL"] as? String) { image in
                if image != nil {
                    DispatchQueue.main.async {
                        avatarView.image = image
                    }
                } else {
                    DispatchQueue.main.async {
                        avatarView.set(avatar: defaultImage)
                    }
                }
            }
        } else if senderID == user2UID {
            loadImageFromURL(url: otherUserData!["profilePicURL"] as? String) { image in
                if image != nil {
                    DispatchQueue.main.async {
                        avatarView.image = image
                        avatarView.tintColor = .clear
                    }
                } else {
                    DispatchQueue.main.async {
                        avatarView.set(avatar: defaultImage)
                    }
                }
            }
        }
    }
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        let senderColor = UIColor(named: "senderColor")!
        let recieverColor = UIColor(named: "recieverColor")!
        return isFromCurrentSender(message: message) ? senderColor: recieverColor
    }
    func getUserByID(forUserId userId: String, completion: @escaping ([String: Any]) -> Void) {
        DatabaseCollections.databses.usersDB.document(userId).getDocument { document, _ in
            if let document = document, document.exists {
                if let userData = document.data() {
                    completion(userData)
                } else {
                    completion([:])
                }
            } else {
                completion([:])
            }
        }
    }
    func loadImageFromURL(url: String?, completion: @escaping(UIImage?) -> Void) {
        if let imageURL = url {
            if let imageurl = URL(string: imageURL) {
                URLSession.shared.dataTask(with: imageurl) { data, _, error in
                    if let error = error {
                        print("Error loading image: \(error.localizedDescription)")
                        completion(UIImage(systemName: "person.circle.fill"))
                        return
                    }
                    if let data = data, let image = UIImage(data: data) {
                        completion(image)
                    } else {
                        let image = UIImage(systemName: "person.circle.fill")
                        completion(image)
                    }
                }.resume()
            }
        }
    }
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        switch detector {
        case .hashtag, .mention, .url: return [.foregroundColor: UIColor.link]
        default: return MessageLabel.defaultAttributes
        }
    }
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    }
    func didSelectURL(_ url: URL) {
        print("\n\n\(url)")
        let application = UIApplication.shared
        application.open(url, options: [:], completionHandler: nil)
        //        let profileVC = UIHostingController(rootView: UserProfileView())
        //        self.present(profileVC, animated: true)
    }
}
