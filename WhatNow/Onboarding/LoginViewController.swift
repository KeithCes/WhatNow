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
        
        self.view.backgroundColor = CustomColors.grayDark
        
        emailField.tintColor = CustomColors.orange
        emailField.textColor = CustomColors.orange
        emailField.lineColor = CustomColors.orange
        emailField.selectedTitleColor = CustomColors.orange
        emailField.selectedLineColor = CustomColors.orange
        emailField.placeholderColor = CustomColors.grayLight
        emailField.placeholder = "Email"
        emailField.title = "Email"
        emailField.returnKeyType = UIReturnKeyType.done
        emailField.delegate = self
        emailField.iconType = .font
        emailField.iconColor = CustomColors.orange
        emailField.selectedIconColor = CustomColors.orange
        emailField.iconFont = UIFont(name: "Font Awesome 5 Free", size: 15)
        emailField.iconText = "\u{f1fa}"
        emailField.iconMarginBottom = 4.0
        emailField.iconMarginLeft = 2.0
        emailField.autocorrectionType = .no
        emailField.autocapitalizationType = .none
        emailField.spellCheckingType = .no
        self.view.addSubview(emailField)
        
        passField.tintColor = CustomColors.orange
        passField.textColor = CustomColors.orange
        passField.lineColor = CustomColors.orange
        passField.selectedTitleColor = CustomColors.orange
        passField.selectedLineColor = CustomColors.orange
        passField.placeholderColor = CustomColors.grayLight
        passField.placeholder = "Password"
        passField.title = "Password"
        passField.isSecureTextEntry = true
        passField.returnKeyType = UIReturnKeyType.done
        passField.delegate = self
        passField.iconType = .font
        passField.iconColor = CustomColors.orange
        passField.selectedIconColor = CustomColors.orange
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
