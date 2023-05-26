//
//  PeopleViewController.swift
//  ChattingPractice
//
//  Created by JongHoon on 2023/05/26.
//

import UIKit
import SnapKit
import FirebaseDatabase

final class PeopleViewController: BaseViewController {
    
    var array: [UserModel] = []
    var tableView: UITableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func setView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "Cell"
        )
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        Database
            .database()
            .reference()
            .child("users")
            .observe(DataEventType.value,
                     with: { snapShot in
                
                self.array.removeAll()
                
                for child in snapShot.children {
                    let fchild = child as! DataSnapshot
                    let userModel = UserModel()
                    
                    print("----------------------")
                    print(fchild)
                    print(fchild)
                    print(fchild)
                    print(fchild)
                    
                    userModel.setValuesForKeys(fchild.value as! [String: Any])
                    self.array.append(userModel)
                }
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.tableView.reloadData()
                }
            })
    }
    
}

extension PeopleViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return array.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "Cell",
            for: indexPath
        )
        
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 50.0 / 2
        imageView.clipsToBounds = true
        cell.addSubview(imageView)
        
        imageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(8.0)
            $0.height.width.equalTo(52.0)
        }
        
        URLSession.shared.dataTask(
            with: URL(string: array[indexPath.row].profileImageUrl ?? "")!,
            completionHandler: { data, response, error in
                DispatchQueue.main.async {
                    imageView.image = UIImage(data: data ?? Data())
                }
            }
        )
        .resume()
        
        let label = UILabel()
        cell.addSubview(label)
        label.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(imageView.snp.trailing).offset(20.0)
        }
        
        label.text = array[indexPath.row].userName
        
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 70.0
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        vc.destinationUid = array[indexPath.row].uid
        navigationController?.pushViewController(vc, animated: true)
    }
}
