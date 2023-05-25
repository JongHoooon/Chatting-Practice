//
//  LoginViewController.swift
//  ChattingPractice
//
//  Created by JongHoon on 2023/05/26.
//

import UIKit
import Firebase

final class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signinButton: UIButton!
    
    let remoteConfig = RemoteConfig.remoteConfig()
    
    let statusBar: UIView = {
        let view = UIView()
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
}

private extension LoginViewController {
    
    func configure() {
        setView()
        setLayout()
    }
    
    func setView() {
        let colorHex: String = remoteConfig["splash_background"].stringValue ?? ""
        let color = UIColor(hex: colorHex)
        statusBar.backgroundColor = color
        loginButton.backgroundColor = color
        signinButton.backgroundColor = color
        
        view.addSubview(statusBar)
    }
    
    func setLayout() {
        statusBar.snp.makeConstraints {
            $0.right.top.left.equalTo(view)
            $0.height.equalTo(20.0)
        }
    }
}
