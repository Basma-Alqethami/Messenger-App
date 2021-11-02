//
//  ViewController.swift
//  Messenger App
//
//  Created by Basma Alqethami on 21/03/1443 AH.
//

import UIKit
import FirebaseAuth

class LogInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func LogIn(_ sender: UIButton) {
        
        guard let Email = emailTextField.text, let Password = passwordTextField.text, !Email.isEmpty, !Password.isEmpty, Password.count >= 6 else {
            alertUserError()
            return
        }
        // Firebase Login
        FirebaseAuth.Auth.auth().signIn(withEmail: Email, password: Password, completion: { [weak self] authResult, error in
            
            guard let strongSelf = self else {
                return
            }
            
            guard let result = authResult, error == nil else {
                print("Failed to log in user with email \(Email)")
                return
            }
            
            let user = result.user.email
            print("logged in user: \(user)")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
    
    func alertUserError(){
        let alert = UIAlertController(title: "Error", message: "Please enter all information.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
}

