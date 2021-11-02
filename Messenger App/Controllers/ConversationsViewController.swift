//
//  ConversationsViewController.swift
//  Messenger App
//
//  Created by Basma Alqethami on 26/03/1443 AH.
//

import UIKit
import FirebaseAuth
class ConversationsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

//        do {
//            try FirebaseAuth.Auth.auth().signOut()
//        }
//        catch {
//        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
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
}


