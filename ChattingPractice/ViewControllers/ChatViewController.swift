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
import ObjectMapper

final class ChatViewController: BaseViewController {
    
    var destinationUid: String?
    var uid: String = Auth.auth().currentUser?.uid ?? ""
    var chatRoomUid: String?
    var comments: [Comment] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkChatRoom()
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
            self.sendButton.isEnabled = false
            
            Database.database().reference()
                .child("chatRooms")
                .childByAutoId()
                .setValue(
                    createRoomInfo,
                    withCompletionBlock: { [weak self] error, ref in
                        guard let self = self else { return }
                        
                        guard error == nil else {
                            print(error?.localizedDescription)
                            return
                        }
                        self.checkChatRoom()
                        
                    }
                )
        } else {
            let value: [String: Any] = [
                    "uid": uid,
                    "message": messageTextField.text ?? ""
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
                        
                        if let chatRoomdic = item.value as? [String: AnyObject] {
                            
                            let chatModel = ChatModel(JSON: chatRoomdic)
                            if chatModel?.users[self.destinationUid ?? ""] == true {
                                self.chatRoomUid = item.key
                                self.sendButton.isEnabled = true
                                self.getMessageList()
                            }
                        }
                        
                    }
                })
    }
    
    func getMessageList() {
        
        Database.database().reference()
            .child("chatRooms")
            .child(chatRoomUid ?? "")
            .child("comments")
            .observe(DataEventType.value, with: { [weak self] dataSnapShot in
                guard let self = self else { return }
                
                self.comments.removeAll()
                
                for item in dataSnapShot.children.allObjects as! [DataSnapshot] {
                    if let comment = Comment(JSON: item.value as! [String: AnyObject]) {
                        self.comments.append(comment)
                    }
                }
                self.tableView.reloadData()
            })
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return comments.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "MessageCell",
            for: indexPath
        )
        cell.textLabel?.text = comments[indexPath.row].message
        
        return cell
    }
}
