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
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configure() {
        getChatRoomsList()
    }
    
}

private extension ChatRoomsViewController {
    
    func getChatRoomsList() {
        
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatRooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "RowCell",
            for: indexPath
        )
        
        
        return cell
    }

}
