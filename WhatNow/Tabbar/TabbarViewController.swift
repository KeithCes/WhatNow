//
//  TabbarViewController.swift
//  WhatNow
//
//  Created by Keith C on 12/28/20.
//

import Foundation
import Firebase
import FirebaseAuth


class TabbarViewController: UITabBarController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = CustomColors.grayDark
        self.tabBar.tintColor = CustomColors.orange
        self.tabBar.barTintColor = CustomColors.grayDark
        self.tabBar.isTranslucent = false
    }
    
}
