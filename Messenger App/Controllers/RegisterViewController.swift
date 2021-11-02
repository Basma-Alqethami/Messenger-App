//
//  RegisterViewController.swift
//  Messenger App
//
//  Created by Basma Alqethami on 21/03/1443 AH.
//

import UIKit
import FirebaseAuth
import Firebase

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var LNameTextField: UITextField!
    @IBOutlet weak var FNameTextField: UITextField!
    @IBOutlet weak var ProfileImage: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ProfileImage.layer.cornerRadius = ProfileImage.frame.size.width/2
        ProfileImage.clipsToBounds = true
    }
    
    @IBAction func AddProfileImage(_ sender: UIButton) {
        presentPhotoActionSheet()
    }
    
    @IBAction func RegisterButton(_ sender: UIButton) {
        
        guard let Email = EmailTextField.text, let Password = PasswordTextField.text, let FirstName = FNameTextField.text, let LastName = LNameTextField.text, !Email.isEmpty, !FirstName.isEmpty, !LastName.isEmpty, !Password.isEmpty, Password.count >= 6 else {
            alertUserError(message: "Please enter all information.")
            return
        }
        
        DatabaseManger.shared.userExists(with: Email, completion: { [weak self] exists in
            
            guard let strongSelf = self else {
                return
            }
            
            guard !exists else {
                self?.alertUserError(message: "User account for that email already exists.")
                return
            }
            
            FirebaseAuth.Auth.auth().createUser(withEmail: Email, password: Password, completion: { authResult , error  in
                guard authResult != nil, error == nil else {
                    print("Error creating user")
                    return
                }
                DatabaseManger.shared.insertUser(with: ChatAppUser (firstName: FirstName,
                                                                    lastName: LastName,
                                                                    emailAddress: Email))
                //let user = result.user
                print("Created User:")
                strongSelf.navigationController?.popViewController(animated: true)
            })
        })
    }
    
    func alertUserError(message: String){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // get results of user taking picture or selecting from camera roll
    func presentPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How would you like to select a picture?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        
        present(actionSheet, animated: true)
    }
    
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // take a photo or select a photo
        
        // action sheet - take photo or choose photo
        picker.dismiss(animated: true, completion: nil)
        print(info)
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        self.ProfileImage.setImage(selectedImage, for: .normal)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
