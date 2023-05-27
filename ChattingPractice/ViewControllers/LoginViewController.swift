//
//  LoginViewController.swift
//  ChattingPractice
//
//  Created by JongHoon on 2023/05/26.
//

import UIKit
import Firebase
import Firebase
import FirebaseMessaging

final class LoginViewController: BaseViewController {
    
    var token: String?
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        try? Auth.auth().signOut()
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
        
        loginButton.addTarget(
            self,
            action: #selector(loginEvent),
            for: .touchUpInside
        )
        
        signupButton.addTarget(
            self,
            action: #selector(presentSignup),
            for: .touchUpInside
        )
        
        Auth.auth().addStateDidChangeListener({ [weak self] auth, user in
            guard let self = self else { return }
            
            if let _ = user {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainViewTabBarController") as! UITabBarController
                vc.modalPresentationStyle = .fullScreen
                let uid = Auth.auth().currentUser?.uid
                
                Messaging.messaging().delegate = self
                
                Messaging.messaging().token { token, error in
                    if let error = error {
                        print("Error fetching FCM registration token: \(error)")
                    } else if let token = token {
                        print("FCM registration token: \(token)")
                        
                        Database.database().reference()
                            .child("users")
                            .child(uid ?? "")
                            .updateChildValues(["pushToken": token])
                    }
                }
                
                self.present(vc, animated: true)
            }
        })
    }
}

// MARK: - action

private extension LoginViewController {
    
    @objc
    func loginEvent() {
        Auth.auth().signIn(
            withEmail: emailTextField.text ?? "",
            password: passwordTextField.text ?? "",
            completion: { [weak self] result, error in
                guard let self = self else { return }
                
                if let error = error {
                    let alert = UIAlertController(
                        title: "error",
                        message: error.localizedDescription,
                        preferredStyle: .alert
                    )
                    alert.addAction(
                        UIAlertAction(
                            title: "확인",
                            style: .default
                        ))
                    
                    self.present(alert, animated: true)
                    return
                }
                
                
            }
        )
        
    }
    
    @objc
    func presentSignup() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
        vc.modalPresentationStyle = .fullScreen
        
        present(vc, animated: true)
    }
}

extension LoginViewController: MessagingDelegate {
    // 토큰 갱신 모니터링
    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        self.token = fcmToken
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
}

