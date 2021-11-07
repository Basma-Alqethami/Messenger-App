//
//  ProfileViewController.swift
//  Messenger App
//
//  Created by Basma Alqethami on 27/03/1443 AH.
//

import UIKit
import FirebaseAuth
import SDWebImage


class ProfileViewController: UIViewController {
    
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var EmailLabel: UILabel!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2
        profileImageView.clipsToBounds = true
        profile ()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
        profile ()
    }
    
    private func validateAuth(){
        // current user is set automatically when you log a user in
        if Auth.auth().currentUser == nil {
            // present login view controller
            let vc = storyboard?.instantiateViewController(withIdentifier: "storyboardLogIn") as! LogInViewController
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }

    func profile () {
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            print("fffffffffffff")
             return
         }
        
        guard let userName = UserDefaults.standard.value(forKey: "name") as? String else {
            print("fffffffffffff")
             return
         }
        
        NameLabel.text = userName
        EmailLabel.text = "Email: \(email)"
        
        print(email)
         let safeEmail = DatabaseManger.safeEmail(emailAddress: email)
         let filename = "\(safeEmail)_profile_picture.png"
        print(filename)
         let path = "images/\(filename)"
        print(path)

        
        
        StorageManager.shared.downloadURL(for: path, completion: { result in
            print("AAAAAAAAAA \(result)")
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    self.profileImageView.sd_setImage(with: url, completed: nil)
                }
            case .failure(let error):
                print("Failed to get download url: \(error)")
            }
        })
    }
    
    @IBAction func LogoutPress(_ sender: UIButton) {
        
        let actionSheet = UIAlertController(title: "Log Out", message: "Are you sure you want to log out", preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in
            
            guard let strongSelf = self else {
                return
            }
            do {
                try Auth.auth().signOut()
                let vc = strongSelf.storyboard?.instantiateViewController(withIdentifier: "storyboardLogIn") as! LogInViewController
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: true)
            }
            catch {
                print("failed to logout")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true)
    }
}

