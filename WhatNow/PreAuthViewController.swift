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
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //logs user in if they are authed already (remember me)
        if Auth.auth().currentUser != nil {
            let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let interestsViewController  = mainStoryboard.instantiateViewController(withIdentifier: "InterestsViewController") as! InterestsViewController
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
        let interestsViewController  = mainStoryboard.instantiateViewController(withIdentifier: "InterestsViewController") as! InterestsViewController
        interestsViewController.modalPresentationStyle = .fullScreen
        self.present(interestsViewController, animated: true, completion: nil)
    }
}
