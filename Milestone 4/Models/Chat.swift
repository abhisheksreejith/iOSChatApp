//
//  Chat.swift
//  Milestone 4
//
//  Created by Abhishek-Sreejith on 04/10/23.
//
import Foundation
struct Chat {
    var users: [String]
    var dictionary: [String: Any] {
        return ["users": users]
    }
}
extension Chat {
    init?(dictionary: [String: Any]) {
        guard let chatUsers = dictionary["users"] as? [String] else { return nil}
        self.init(users: chatUsers)
    }
}
