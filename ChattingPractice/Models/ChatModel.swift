//
//  ChatModel.swift
//  ChattingPractice
//
//  Created by JongHoon on 2023/05/27.
//

import Foundation
import ObjectMapper

@objcMembers
final class ChatModel: Mappable {
    var users: Dictionary<String, Bool> = [:]    // 참여한 사람들
    var comments: Dictionary<String, Comment> = [:] // 대화 내용
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        users <- map["users"]
        comments <- map["comments"]
    }
}

class Comment: Mappable {
    var uid: String?
    var message: String?
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        uid <- map["uid"]
        message <- map["message"]
    }
}
