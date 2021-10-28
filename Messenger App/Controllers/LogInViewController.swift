//
//  ViewController.swift
//  Messenger App
//
//  Created by Basma Alqethami on 21/03/1443 AH.
//

import UIKit
import FirebaseAuth
class LogInViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Firebase Login
        FirebaseAuth.Auth.auth().signIn(withEmail: "bas@gmail.com", password: "123456", completion: { authResult, error in
            guard let result = authResult, error == nil else {
                print("Failed to log in user with email bas@gmail.com")
                return
            }
            let user = result.user
            print("logged in user: \(user)")
        })
    }


}

