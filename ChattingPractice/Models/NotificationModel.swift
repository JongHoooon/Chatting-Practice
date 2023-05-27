//
//  NotificationModel.swift
//  ChattingPractice
//
//  Created by JongHoon on 2023/05/27.
//

import ObjectMapper

class NotificationModel: Mappable {
    
    var to: String?
    var notification: ChatNotification = ChatNotification()
    
    init() {}
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        to <- map["to"]
        notification <- map["notification"]
    }
}

class ChatNotification: Mappable {
    
    var title: String?
    var text: String?
    
    init() {}
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        title <- map["title"]
        text <- map["text"]
    }
}
