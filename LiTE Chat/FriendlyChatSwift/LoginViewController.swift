//
//  LoginViewController.swift
//  FriendlyChatSwift
//
//  Created by osama on 10/2/18.
//  Copyright © 2018 Google Inc. All rights reserved.
//

import UIKit
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    var _authHandle: AuthStateDidChangeListenerHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        let provider: [FUIAuthProvider] = [FUIGoogleAuth()]
        FUIAuth.defaultAuthUI()?.providers = provider
        
        // listen for changes in the authorization state
            _authHandle = Auth.auth().addStateDidChangeListener { (auth: Auth, user: User?) in
            // refresh table data
            
            // check if there is a current user
            if let activeUser = user {//user logged in
                
                let email = (Auth.auth().currentUser?.email)!.replacingOccurrences(of: ".", with: "_")
                let testDict:[String:String] = ["mail":String( email)]
                let ref = Database.database().reference()
                ref.child("registeredUsers").child(email).setValue(testDict, withCompletionBlock: { (error, ref) in
                    
                    self.spinner.stopAnimating()
                    self.performSegue(withIdentifier:"ChatSelect" , sender: self)
                })
                
                }
            else{
                let authViewController = FUIAuth.defaultAuthUI()!.authViewController()
                self.present(authViewController, animated: true, completion: nil)

            }
        }
    }
                
    
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    deinit{
        Auth.auth().removeStateDidChangeListener(_authHandle)
    }
}
