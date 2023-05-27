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
import Alamofire

final class ChatViewController: BaseViewController {
    
    var destinationUid: String?
    var uid: String = Auth.auth().currentUser?.uid ?? ""
    var chatRoomUid: String?
    var comments: [Comment] = []
    var destinationUserModel: UserModel?
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkChatRoom()
        
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func setView() {
        tableView.separatorStyle = .none
    }
    
    override func setAction() {
        sendButton.addTarget(
            self,
            action: #selector(createRoom),
            for: .touchUpInside
        )
        
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        view.addGestureRecognizer(tap)
    }
}

private extension ChatViewController {
    
    @objc
    func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            bottomConstraint.constant = -keyboardSize.height
            
            UIView.animate(
                withDuration: 0,
                animations: { [weak self] in
                    guard let self = self else { return }
                    
                    self.view.layoutIfNeeded()
                },
                completion: { _ in
                    if self.comments.count > 0 {
                        self.tableView.scrollToRow(
                            at: IndexPath(row: self.comments.count - 1, section: 0),
                            at: .bottom,
                            animated: false
                        )
                    }
                })
        }
    }
    
    @objc
    func keyboardWillHide(notification: Notification) {
        bottomConstraint.constant = 0
        self.view.layoutIfNeeded()
    }
    
    @objc
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
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
                    "message": messageTextField.text ?? "",
                    "timeStamp": ServerValue.timestamp()
            ]
            
            Database.database().reference()
                .child("chatRooms")
                .child(chatRoomUid ?? "")
                .child("comments")
                .childByAutoId()
                .setValue(
                    value,
                    withCompletionBlock: { [weak self] error, ref in
                        guard let self = self else { return }
                        guard error == nil else {
                            print(error.debugDescription)
                            return
                        }
                        
                        self.sendGcm()
                        self.messageTextField.text = ""
                })
        }
        
    }
    
    func sendGcm() {
        
        let url = "https://fcm.googleapis.com/fcm/send"
        
        let header: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "key=AAAA5IMbg5c:APA91bHIdEXe36f-r1MAPzcDISQC_6bdFuaCKFXWri4OWf1XpbNMLD84DeTf6nkrO3BjEN_y9JAye7W1jTqwRr30BOY-OEmY8utvyw_-dIkZL4dBiZnSJxPzA5P4jQ0QdcuqcBySF_lp"
        ]
        
        var notificationModel = NotificationModel()
        notificationModel.to = destinationUserModel?.pushToken ?? ""
        notificationModel.notification.title = "보낸이 아이디"
        notificationModel.notification.text = messageTextField.text ?? ""
        
        print("------------------------")
        print(notificationModel.to)
        print(notificationModel.notification.title)
        print(notificationModel.notification.text)
        
        let params = notificationModel.toJSON()
        
        AF.request(
            url,
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: header
        )
        .responseJSON(completionHandler: { response in
            print("-----------------------------------")
            print(response.value)
        })
        .resume()
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
                                self.getDestinationInfo()
                            }
                        }
                        
                    }
                })
    }
    
    func getDestinationInfo() {
        Database.database().reference()
            .child("users")
            .child(destinationUid ?? "")
            .observeSingleEvent(
                of: .value,
                with: { [weak self] dataSnapshot in
                    guard let self = self else { return }
                
                    self.destinationUserModel = UserModel()
                    self.destinationUserModel?.setValuesForKeys(dataSnapshot.value as! [String: Any])
                    self.getMessageList()
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
                
                if self.comments.count > 0 {
                    self.tableView.scrollToRow(
                        at: IndexPath(row: self.comments.count - 1, section: 0),
                        at: .bottom,
                        animated: false
                    )
                }
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
        
        if comments[indexPath.row].uid == uid {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "MyMessageCell",
                for: indexPath
            ) as! MyMessageCell
            
            let comment = comments[indexPath.row]
            cell.messageLabel.text = comment.message
            cell.messageLabel.numberOfLines = 0
            
            cell.timeStampLabel.text = comment.timeStamp?.toDayTime
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "DestinationMessageCell",
                for: indexPath
            ) as! DestinationMessageCell
            
            cell.nameLabel.text = destinationUserModel?.userName
            
            
            
            let url = URL(string: destinationUserModel?.profileImageUrl ?? "")
            URLSession.shared.dataTask(with: url!, completionHandler: { data, _, error in
                
                DispatchQueue.main.async {
                    cell.profileImageVIew.image = UIImage(data: data ?? Data())
                }
            })
            .resume()
            
            cell.profileImageVIew.layer.cornerRadius = cell.profileImageVIew.frame.width / 2
            cell.profileImageVIew.clipsToBounds = true
            
            let comment = comments[indexPath.row]
            cell.messageLabel.text = comment.message
            cell.messageLabel.numberOfLines = 0
            
            cell.timeStampLabel.text = comment.timeStamp?.toDayTime
            
            return cell
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return UITableView.automaticDimension
    }
}


