//
//  PreAuthViewController.swift
//  WhatNow
//
//  Created by Keith C on 12/28/20.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth

class PreAuthViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //if user preferences are nil populate here
        let ref = Database.database().reference()
        let userID = Auth.auth().currentUser!.uid
        let defaultPreferences = DefaultPreferencesUser.defaultPreferences
        ref.child("users").child(userID).child("preferences").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value == nil {
                ref.child("users").child(userID).child("preferences").setValue(defaultPreferences)
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //logs user in if they are authed already (remember me)
        if Auth.auth().currentUser != nil {
            let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let interestsViewController  = mainStoryboard.instantiateViewController(withIdentifier: "TabbarViewController") as! TabbarViewController
            interestsViewController.modalPresentationStyle = .fullScreen
            self.present(interestsViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func createAccountPressed(_ sender: Any) {
        let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let interestsViewController  = mainStoryboard.instantiateViewController(withIdentifier: "CreateAccountViewController") as! CreateAccountViewController
        interestsViewController.modalPresentationStyle = .fullScreen
        self.present(interestsViewController, animated: true, completion: nil)
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let interestsViewController  = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        interestsViewController.modalPresentationStyle = .fullScreen
        self.present(interestsViewController, animated: true, completion: nil)
    }
}
