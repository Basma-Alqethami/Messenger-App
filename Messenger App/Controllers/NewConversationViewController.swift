//
//  NewConversationViewController.swift
//  Messenger App
//
//  Created by Basma Alqethami on 27/03/1443 AH.
//

import UIKit
import JGProgressHUD
import SDWebImage


struct SearchResult {
    let name: String
    let email: String
}

class NewConversationViewController: UIViewController {

    public var completion: ((SearchResult) -> (Void))?
    
    private var results = [SearchResult]()
    private var Fetched = false
    
    private var users = [[String: String]]()

    private let spinner = JGProgressHUD(style: .dark)
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    
}

extension NewConversationViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismiss(animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        results.removeAll()
        spinner.show(in: view)
        searchUsers(query: text)
    }

    func searchUsers(query: String) {
        if Fetched {
            filterUsers(with: query)
        }
        else {
            DatabaseManger.shared.getAllUsers(completion: { [weak self] result in
                switch result {
                case .success(let usersCollection):
                    self?.Fetched = true
                    self?.users = usersCollection
                    print("Users: \(usersCollection)")
                    self?.filterUsers(with: query)
                case .failure(let error):
                    print("Failed to get usres: \(error)")
                }
            })
        }
    }

    func filterUsers(with term: String) {
        
        self.spinner.dismiss()
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String, Fetched else {
            return
        }

        let safeEmail = DatabaseManger.safeEmail(emailAddress: currentUserEmail)
        
        
        let results: [SearchResult] = self.users.filter({

            guard let email = $0["email"], email != safeEmail else {
                return false
            }
            
            guard let email = $0["email"]?.lowercased() else {
                return false
            }
            
            let safeEmail = DatabaseManger.safeEmail(emailAddress: term)
            
            return email.hasPrefix(safeEmail.lowercased())
        }) .compactMap ({
            
            guard let email = $0["email"], let name = $0["name"] else {
                return nil
            }

            return SearchResult(name: name, email: email)
        })

        self.results = results
        print(self.results)
        tableView.reloadData()
    }
}

extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewConversationCell", for: indexPath) as! NewConversationCell
        cell.NameLabel.text = self.results[indexPath.row].name
        
        cell.imageViewProfile.layer.cornerRadius = cell.imageViewProfile.frame.size.width/2
        cell.imageViewProfile.clipsToBounds = true
        let path = "images/\(self.results[indexPath.row].email)_profile_picture.png"
        StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    cell.imageViewProfile.sd_setImage(with: url, completed: nil)
                }
            case .failure(let error):
                print("failed to get image url: \(error)")
            }
        })
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let UserData = results[indexPath.row]
        dismiss(animated: true, completion: { [weak self] in
            self?.completion?(UserData)
        })
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

