//
//  UserContext.swift
//  BxForum
//
//  Created by Mars on 2018/9/25.
//  Copyright © 2018 Mars. All rights reserved.
//

import Foundation

struct Forum: Codable {
  var id: UInt
  var name: String
  
  init(id: UInt, name: String) {
    self.id = id
    self.name = name
  }
}

struct UserContext: Codable {
  var username: String
  var forums: [Forum]
  
  init(username: String, forums: [Forum]) {
    self.username = username
    self.forums = forums
  }
}

struct Message: Codable {
  var id: Int?
  var forumId: Int
  var title: String
  var content: String
  var originId: Int
  var author: String
  var createdAt: Date
}

struct MessageContext: Codable {
  var username: String?
  var forum: Forum
  var messages: [Message]
}

struct ReplyContext: Codable {
  var username: String?
  var forum: Forum
  var message: Message
  var replies: [Message]
}
