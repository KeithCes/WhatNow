//
//  LoginViewController.swift
//  WhatNow
//
//  Created by Keith C on 12/28/20.
//

import Foundation
import UIKit
import FirebaseAuth
import Firebase
import SkyFloatingLabelTextField


class LoginViewController: UIViewController, UITextFieldDelegate {
    
    var password = ""
    var email = ""

    let emailField = SkyFloatingLabelTextFieldWithIcon(frame: CGRect(x: (screenWidth/2) - 100, y: (screenHeight/2) - 150, width: 200, height: 45))
    let passField = SkyFloatingLabelTextFieldWithIcon(frame: CGRect(x: (screenWidth/2) - 100, y: (screenHeight/2) - 100, width: 200, height: 45))
     
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        

    //    let lightGreyColor = UIColor(red: 197/255, green: 205/255, blue: 205/255, alpha: 1.0)
        let purple = UIColor(red: 148/255, green: 125/255, blue: 162/255, alpha: 1.0)
        
        emailField.tintColor = purple
        emailField.textColor = purple
        emailField.lineColor = purple
        emailField.selectedTitleColor = purple
        emailField.selectedLineColor = purple
        emailField.placeholder = "Email"
        emailField.title = "Email"
        emailField.returnKeyType = UIReturnKeyType.done
        emailField.delegate = self
        emailField.iconType = .font
        emailField.iconColor = UIColor(red: 148/255, green: 125/255, blue: 162/255, alpha: 1.0)
        emailField.selectedIconColor = purple
        emailField.iconFont = UIFont(name: "Font Awesome 5 Free", size: 15)
        emailField.iconText = "\u{f1fa}"
        emailField.iconMarginBottom = 4.0
        emailField.iconMarginLeft = 2.0
        emailField.autocorrectionType = .no
        emailField.autocapitalizationType = .none
        emailField.spellCheckingType = .no
        self.view.addSubview(emailField)
        
        passField.tintColor = purple
        passField.textColor = purple
        passField.lineColor = purple
        passField.selectedTitleColor = purple
        passField.selectedLineColor = purple
        passField.placeholder = "Password"
        passField.title = "Password"
        passField.isSecureTextEntry = true
        passField.returnKeyType = UIReturnKeyType.done
        passField.delegate = self
        passField.iconType = .font
        passField.iconColor = UIColor(red: 148/255, green: 125/255, blue: 162/255, alpha: 1.0)
        passField.selectedIconColor = purple
        passField.iconFont = UIFont(name: "Font Awesome 5 Free", size: 15)
        passField.iconText = "\u{f023}"
        passField.iconMarginBottom = 4.0
        passField.iconMarginLeft = 2.0
        self.view.addSubview(passField)
         
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        submit()
        textField.resignFirstResponder()
        return true
    }
    
    func submit() {
        email = emailField.text!
        password = passField.text!
        
        
        Auth.auth().signIn(withEmail: email, password: password) { username, error in
            if error == nil && username != nil {
                print("logged in")
                userEmail = self.emailField.text!
                
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
                
                self.transitionToMain()
            }
            else {
                print("error:  \(error!.localizedDescription)")
            }
        }
    }
    
    
    func transitionToMain() {
        let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let interestsViewController  = mainStoryboard.instantiateViewController(withIdentifier: "TabbarViewController") as! TabbarViewController
        interestsViewController.modalPresentationStyle = .fullScreen
        self.present(interestsViewController, animated: true, completion: nil)
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
