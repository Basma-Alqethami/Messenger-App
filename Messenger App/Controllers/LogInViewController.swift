//
//  ViewController.swift
//  Messenger App
//
//  Created by Basma Alqethami on 21/03/1443 AH.
//


import UIKit
import FirebaseAuth
import FBSDKLoginKit
import JGProgressHUD


class LogInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    private let spinner = JGProgressHUD(style: .dark)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        let loginButton =
//        loginButton.center = view.center
//        view.addSubview(loginButton)
    }
    
    @IBAction func FacebookLogin(_ sender: UIButton) {
//        let loginManager = LoginManager()
//
//            loginManager.logIn(permissions: [], from: self) { [weak self] (result, error) in
//                guard error == nil else {
//                    // Error occurred
//                    print(error!.localizedDescription)
//                    return
//                }
//                guard let result = result, !result.isCancelled else {
//                    print("User cancelled login")
//                    return
//                }
//
//                Profile.loadCurrentProfile { (profile, error) in
//                }
//            }
        }
    
    @IBAction func LogIn(_ sender: UIButton) {
        
        guard let Email = emailTextField.text, let Password = passwordTextField.text, !Email.isEmpty, !Password.isEmpty, Password.count >= 6 else {
            alertUserError()
            return
        }
        
        spinner.show(in: view)
        
        // Firebase Login
        FirebaseAuth.Auth.auth().signIn(withEmail: Email, password: Password, completion: { [weak self] authResult, error in
            
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard let result = authResult, error == nil else {
                print("Failed to log in user with email \(Email)")
                return
            }
            
            let safeEmail = DatabaseManger.safeEmail(emailAddress: Email)
            DatabaseManger.shared.getDataFor(path: safeEmail, completion: { result in
                   switch result {
                   case .success(let data):
                       guard let userData = data as? [String: Any],
                           let firstName = userData["first_name"] as? String,
                           let lastName = userData["last_name"] as? String else {
                               return
                       }
                       UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")

                   case .failure(let error):
                       print("Failed to read data with error \(error)")
                   }
               })
            
            
            let user = result.user.email
            print("logged in user: \(String(describing: user))")
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            UserDefaults.standard.set(Email, forKey: "email")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
    
    func alertUserError(){
        let alert = UIAlertController(title: "Error", message: "Please enter all information.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}
