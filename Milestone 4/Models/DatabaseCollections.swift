//
//  DatabaseCollections.swift
//  Milestone 4
//
//  Created by Abhishek-Sreejith on 10/10/23.
//

import Foundation
import FirebaseFirestore
class DatabaseCollections {
    static let databses = DatabaseCollections()
    let firebase = Firestore.firestore()
    let usersDB = Firestore.firestore().collection("users")
    let chatsDB = Firestore.firestore().collection("chats")
}
