//
//  ChatModel.swift
//  ChattingPractice
//
//  Created by JongHoon on 2023/05/27.
//

import Foundation

@objcMembers
final class ChatModel: NSObject {
    var user: Dictionary<String, Bool> = [:]    // 참여한 사람들
    var comments: Dictionary<String, Comment> = [:] // 대화 내용
}

class Comment {
    var uid: String?
    var message: String?
}
