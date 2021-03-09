//
//  SettingsViewController.swift
//  WhatNow
//
//  Created by Keith C on 12/28/20.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth

class SettingsViewController: UIViewController {
    
    override func viewDidLoad() {
        self.view.backgroundColor = CustomColors.grayDark
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        try! Auth.auth().signOut()
        
        print("logged out")
        
        self.dismiss(animated: true, completion: nil)
    }
}
