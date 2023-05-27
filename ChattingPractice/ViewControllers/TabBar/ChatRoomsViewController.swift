//
//  ChatRoomsViewController.swift
//  ChattingPractice
//
//  Created by JongHoon on 2023/05/27.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

final class ChatRoomsViewController: BaseViewController {
    
    let uid = Auth.auth().currentUser?.uid ?? ""
    var chatRooms: [ChatModel] = []
    var destinationUsers: [String] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getChatRoomsList()
    }
    
    override func configure() {
        tableView.register(
            ChatListCell.self,
            forCellReuseIdentifier: "ChatListCell"
        )
    }
}

private extension ChatRoomsViewController {
    
    func getChatRoomsList() {
        
        chatRooms.removeAll()
        Database.database().reference()
            .child("chatRooms")
            .queryOrdered(byChild: "users/"+uid)
            .queryEqual(toValue: true)
            .observeSingleEvent(
                of: .value,
                with: { [weak self] dataSnapshot in
                    guard let self = self else { return }
                    
                    for item in dataSnapshot.children.allObjects as! [DataSnapshot] {
                        
                        if let chatRoomDic = item.value as? [String: AnyObject] {
                            
                            if let chatModel = ChatModel(JSON: chatRoomDic) {
                                self.chatRooms.append(chatModel)
                            }
                        }
                    }
                    self.tableView.reloadData()
            })
    }
}

extension ChatRoomsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return chatRooms.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ChatListCell",
            for: indexPath
        ) as! ChatListCell
        
        var destinationUid: String = ""
        
        for item in chatRooms[indexPath.row].users {
            if item.key != uid {
                destinationUid = item.key
                destinationUsers.append(destinationUid)
            }
        }
        
        Database.database().reference()
            .child("users")
            .child(destinationUid)
            .observeSingleEvent(of: .value, with: { [weak self] dataSnapshot in
                guard let self = self else { return }
                
                let userModel = UserModel()
                userModel.setValuesForKeys(dataSnapshot.value as! [String: AnyObject])
                
                cell.titleLabel.text = userModel.userName
                
                if let url = URL(string: userModel.profileImageUrl ?? "") {
                    URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
                        
                        DispatchQueue.main.async {
                            cell.profileImageView.image = UIImage(data: data ?? Data())
                        }
                    })
                    .resume()
                    
                    let lastMessageKey = self.chatRooms[indexPath.row].comments.keys.sorted(by: >)
                    cell.lastMessageLabel.text = self.chatRooms[indexPath.row].comments[lastMessageKey[0]]?.message
                    
                    let unixTime = self.chatRooms[indexPath.row].comments[lastMessageKey[0]]?.timeStamp
                    
                    cell.timeStampLabel.text = unixTime?.toDayTime
                }
            })
        
        
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let destinationUid = destinationUsers[indexPath.row]
        let vc = storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        vc.destinationUid = destinationUid
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
}


