//
//  InterestsViewController.swift
//  WhatNow
//
//  Created by Keith C on 12/22/20.
//

import UIKit
import Foundation
import Firebase

class InterestsViewController: UIViewController {
    
    @IBOutlet weak var interestsImage: UIImageView!
    
    var videoGames: [[String:Any]] = []
    
    override func viewDidLoad() {
        
        //TODO: connect to firebase and pull ARRAY of STRING DICT of all video games, delete test values
        
        let items = [["imageName": "enemy.png", "title": "The Witcher 3", "genre": "adventure", "multiplayer": false, "difficulty": 5, "competitive": 1, "popularity": 9], ["imageName": "jolie.png", "title": "Minecraft", "genre": "adventure", "multiplayer": false, "difficulty": 5, "competitive": 1, "popularity": 9]]
        
        videoGames = items
        
        interestsImage.image = UIImage(named: videoGames[0]["imageName"] as! String)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        var ref: DatabaseReference!

        ref = Database.database().reference()

        if let swipeGesture = gesture as? UISwipeGestureRecognizer {

            switch swipeGesture.direction {
            case .right:
                print("Swiped right")
                let rand = Int.random(in: 0..<videoGames.count)
                interestsImage.image = UIImage(named: videoGames[rand]["imageName"] as! String)
            case .left:
                print("Swiped left")
            default:
                break
            }
        }
    }
}
