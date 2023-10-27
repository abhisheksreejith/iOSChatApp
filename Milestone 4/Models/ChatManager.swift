import FirebaseFirestore


class ChatManager {
    static let shared = ChatManager()
    
    private let db = Firestore.firestore()
    private let chatsCollection = "chats"
    private let usersCollection = "users"
    
    func getOtherUserIDsSortedByLastMessage(currentUserUID: String, completion: @escaping ([String]) -> Void) {
        let chatsCollection = Firestore.firestore().collection("chats")
        
        // Query for chat documents where the current user is present
        let query = chatsCollection.whereField("users", arrayContains: currentUserUID).order(by: "lastMessage", descending: true)
        // Order the results by the "lastmessage" field in descending order (latest first)
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching chat documents: \(error.localizedDescription)")
                completion([])
            } else if let chatDocuments = querySnapshot?.documents {
                var userIDs: [String] = []
                print(chatDocuments)
                // DispatchQueue.main.async {
                
                for chatDocument in chatDocuments {
                    let users = chatDocument.data()["users"] as? [String] ?? []
                    // Filter out the current user's ID
                    let otherUserIDs = users.filter { $0 != currentUserUID }
                    // Ensure there are other users in the chat
                    if let otherUserID = otherUserIDs.first {
                        userIDs.append(otherUserID)
                    }
                }
                userIDs.sort { (userID1, userID2) -> Bool in
                    if let timestamp1 = (chatDocuments.first(where: { $0.data()["users"] as? [String] ?? [] == [currentUserUID, userID1] })?.data()["lastMessage"] as? Timestamp),
                       let timestamp2 = (chatDocuments.first(where: { $0.data()["users"] as? [String] ?? [] == [currentUserUID, userID2] })?.data()["lastMessage"] as? Timestamp) {
                        return timestamp1.compare(timestamp2) == .orderedDescending
                    }
                    return false
                }
                print(userIDs)
                completion(userIDs)
            } else {
                print("No chat documents found.")
                completion([])
            }
        }
    }
}


