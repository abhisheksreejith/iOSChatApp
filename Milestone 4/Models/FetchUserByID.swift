//
//  FetchUserByID.swift
//  Milestone 4
//
//  Created by Abhishek-Sreejith on 14/10/23.
//

import Foundation
class FetchUserByID {
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
}
