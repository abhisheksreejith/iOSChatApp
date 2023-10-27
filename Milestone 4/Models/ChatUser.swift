//
//  ChatUser.swift
//  Milestone 4
//
//  Created by Abhishek-Sreejith on 04/10/23.
//
import Foundation
import MessageKit
struct ChatUser: SenderType, Equatable {
    var senderId: String
    var displayName: String
}
