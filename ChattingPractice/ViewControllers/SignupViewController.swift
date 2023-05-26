//
//  SignupViewController.swift
//  ChattingPractice
//
//  Created by JongHoon on 2023/05/26.
//

import UIKit
import Firebase
import TextFieldEffects
import FirebaseAuth
import FirebaseDatabase

final class SignupViewController: BaseViewController {
    
    @IBOutlet weak var emailTextField: HoshiTextField!
    @IBOutlet weak var nameTextField: HoshiTextField!
    @IBOutlet weak var passwordTextField: HoshiTextField!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func setView() {
        
        [
            signupButton,
            cancelButton
        ].forEach { $0?.backgroundColor = remoteColor }
    }
    
    override func setAction() {
        cancelButton.addTarget(
            self,
            action: #selector(dismissVC),
            for: .touchUpInside
        )
        
        signupButton.addTarget(
            self,
            action: #selector(signupEvent),
            for: .touchUpInside
        )
    }
}

// MARK: - Private Method

private extension SignupViewController {

}


// MARK: - Action

private extension SignupViewController {
    
    @objc
    func dismissVC() {
        dismiss(animated: true)
    }
    
    @objc
    func signupEvent() {
        Auth.auth().createUser(
            withEmail: emailTextField.text ?? "",
            password: passwordTextField.text ?? "",
            completion: { [weak self] user, err in
                guard let self = self else { return }
                let uid = user?.user.uid
                Database
                    .database()
                    .reference()
                    .child(uid ?? "")
                    .setValue(["name": self.nameTextField.text ?? ""])
            }
        )
    }
}

