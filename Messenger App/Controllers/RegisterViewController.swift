//
//  RegisterViewController.swift
//  Messenger App
//
//  Created by Basma Alqethami on 21/03/1443 AH.
//

import UIKit
import FirebaseAuth
import Firebase
import JGProgressHUD


class RegisterViewController: UIViewController {
    
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var LNameTextField: UITextField!
    @IBOutlet weak var FNameTextField: UITextField!
    private let spinner = JGProgressHUD(style: .dark)
    @IBOutlet weak var ImageViewProfile: UIImageView!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ImageViewProfile.layer.cornerRadius = ImageViewProfile.frame.size.width/2
        ImageViewProfile.clipsToBounds = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(RegisterViewController.tappedMe))
        ImageViewProfile.addGestureRecognizer(tap)
        ImageViewProfile.isUserInteractionEnabled = true
    }
    
    @objc func tappedMe() {
        presentPhotoActionSheet()
    }
    
    
    @IBAction func RegisterButton(_ sender: UIButton) {
        
        guard let Email = EmailTextField.text, let Password = PasswordTextField.text, let FirstName = FNameTextField.text, let LastName = LNameTextField.text, !Email.isEmpty, !FirstName.isEmpty, !LastName.isEmpty, !Password.isEmpty else {
            errorLabel.text = "Please enter all information."
            return
        }
        
        guard Password.count >= 6 else {
            errorLabel.text = "The password must be 6 digits or more"
            return
        }
        
        guard let img = ImageViewProfile.image, img != UIImage(systemName: "person.crop.circle") else {
            errorLabel.text = "Add an image."
            return
        }
        
        spinner.show(in: view)

        DatabaseManger.shared.userExists(with: Email, completion: { [weak self] exists in
            
            guard let strongSelf = self else {
                return
            }
            
            print(exists)
            guard !exists else {
                DispatchQueue.main.async {
                    strongSelf.errorLabel.text = "User account for that email already exists."
                }
                return
            }
            
            UserDefaults.standard.setValue(Email, forKey: "email")
            UserDefaults.standard.setValue("\(FirstName) \(LastName)", forKey: "name")
            
            FirebaseAuth.Auth.auth().createUser(withEmail: Email, password: Password, completion: { authResult , error  in
                guard authResult != nil, error == nil else {
                    print("Error creating user")
                    return
                }
                
                let User = ChatAppUser (firstName: FirstName, lastName: LastName,emailAddress: Email)
                DatabaseManger.shared.insertUser(with:User , completion: { success in
                    if success {
                        
                        guard let image = strongSelf.ImageViewProfile.image, let data = image.pngData() else {
                            return
                        }

                        let fileName = User.profilePictureUrl
                        StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName, completion: {result in
                            switch result {
                            case .failure(let error):
                                print("error: \(error)")
                            case .success(let imgUrl):
                                UserDefaults.standard.set(imgUrl, forKey: "profile_picture_url")
                                print("save: \(imgUrl)")
                            }
                        })
                    }
                })
                print("Created User:")
                DispatchQueue.main.async {
                    strongSelf.spinner.dismiss()
                }
                
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            })
            })
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
        self.ImageViewProfile.image = selectedImage
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
