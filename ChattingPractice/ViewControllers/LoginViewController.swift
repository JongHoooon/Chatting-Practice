//
//  LoginViewController.swift
//  ChattingPractice
//
//  Created by JongHoon on 2023/05/26.
//

import UIKit
import Firebase

final class LoginViewController: BaseViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    
    override func setView() {
        let colorHex: String = remoteConfig["splash_background"].stringValue ?? ""
        let color = UIColor(hex: colorHex)
        statusBar.backgroundColor = color
        loginButton.backgroundColor = color
        signupButton.backgroundColor = color
        
        view.addSubview(statusBar)
    }
    
    override func setAction() {
        signupButton.addTarget(
            self,
            action: #selector(presentSignup),
            for: .touchUpInside
        )
    }
}

// MARK: - action

private extension LoginViewController {
    
    @objc
    func presentSignup() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
        vc.modalPresentationStyle = .fullScreen
        
        present(vc, animated: true)
    }
}
