//
//  Message.swift
//  Milestone 4
//
//  Created by Abhishek-Sreejith on 04/10/23.
//
import Foundation
import FirebaseFirestore
import MessageKit
struct Message {
    var id: String
    var content: String
    var created: Timestamp
    var senderId: String
    var senderName: String
    var dictionary: [String: Any] {
        return["id": id, "content": content, "created": created, "senderId": senderId, "senderName": senderName]
    }
}
extension Message {
    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let content = dictionary["content"] as? String,
              let created = dictionary["created"] as? Timestamp,
              let senderId = dictionary["senderId"] as? String,
              let senderName = dictionary["senderName"] as? String
        else { return nil }
        self.init(id: id, content: content, created: created, senderId: senderId, senderName: senderName)
    }
}
extension Message: MessageType {
    var sender: SenderType {
        return ChatUser(senderId: senderId, displayName: senderName)
    }
    var messageId: String {
        return id
    }
    var sentDate: Date {
        return created.dateValue()
    }
    var kind: MessageKind {
        return .text(content)
    }
}
