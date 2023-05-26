//
//  ChatViewController.swift
//  ChattingPractice
//
//  Created by JongHoon on 2023/05/27.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

final class ChatViewController: BaseViewController {
    
    var destinationUid: String?
    var uid: String = Auth.auth().currentUser?.uid ?? ""
    var chatRoomUid: String?
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setAction() {
        sendButton.addTarget(
            self,
            action: #selector(createRoom),
            for: .touchUpInside
        )
    }
}

private extension ChatViewController {
    
    @objc
    func createRoom() {
        let createRoomInfo: [String: Any] = [
            "users": [
                uid: true,
                destinationUid ?? "": true
            ]
        ]
        
        if chatRoomUid == nil {
            Database.database().reference()
                .child("chatRooms")
                .childByAutoId()
                .setValue(createRoomInfo)
        } else {
            let value: [String: Any] = [
                "Comments": [
                    "uid": uid,
                    "message": messageTextField.text ?? ""
                ]
            ]
            
            Database.database().reference()
                .child("chatRooms")
                .child(chatRoomUid ?? "")
                .child("comments")
                .childByAutoId()
                .setValue(value)
        }
        
    }
    
    func checkChatRoom() {
        
        Database.database().reference()
            .child("chatRooms")
            .queryOrdered(byChild: "users/"+uid)
            .queryEqual(toValue: true)
            .observeSingleEvent(
                of: DataEventType.value,
                with: { [weak self] dataSnapshot in
                    guard let self = self else { return }
                    
                    for item in dataSnapshot.children.allObjects as! [DataSnapshot] {
                        self.chatRoomUid = item.key
                    }
                })
                    
    }
}
