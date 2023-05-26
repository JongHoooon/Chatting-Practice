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
import FirebaseStorage

final class SignupViewController: BaseViewController {
    
    @IBOutlet weak var emailTextField: HoshiTextField!
    @IBOutlet weak var nameTextField: HoshiTextField!
    @IBOutlet weak var passwordTextField: HoshiTextField!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func setView() {
        
        [
            signupButton,
            cancelButton
        ].forEach { $0?.backgroundColor = remoteColor }
        
        imageView.isUserInteractionEnabled = true
        let imageTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(presentImagePicker)
        )
        imageView.addGestureRecognizer(imageTapGesture)
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

// MARK: - Image Picker

extension SignupViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @objc
    func presentImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imageView.image = image
        
        dismiss(animated: true)
    }
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
            completion: { [weak self] user, error in
                
                if let error = error {
                    print(error)
                    return
                }
                
                guard let self = self else { return }
                let uid = user?.user.uid ?? ""
                let image = self
                    .imageView
                    .image?
                    .jpegData(compressionQuality: 0.1)
                let metaData = StorageMetadata()
                metaData.contentType = "image/jpeg"
                
                
                let reference = Storage
                    .storage()
                    .reference()
                    .child("userImages")
                    .child(uid)
                
                reference
                    .putData(
                        image ?? Data(),
                        metadata: metaData,
                        completion: { metaData, erro in
                            
                            reference.downloadURL(completion: { url, _ in
                                let imageURL = url?.absoluteString ?? ""
                                
                                Database
                                    .database()
                                    .reference()
                                    .child("users")
                                    .child(uid)
                                    .setValue([
                                        "userName": self.nameTextField.text ?? "",
                                        "profileImageUrl": imageURL
                                    ])
                            })
                        })
            }
        )
    }
}
