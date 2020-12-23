//
//  InterestsViewController.swift
//  WhatNow
//
//  Created by Keith C on 12/22/20.
//

import UIKit
import Foundation
import Firebase
import FirebaseDatabase

class InterestsViewController: UIViewController {
    
    @IBOutlet weak var interestsImage: UIImageView!
    
    var ref: DatabaseReference!
    
    var videoGames: [[String:Any]] = []
    
    var defaultPreferences = DefaultPreferencesUser.defaultPreferences
    
    override func viewDidLoad() {
        
        ref = Database.database().reference()
        
        //TODO: connect to firebase and pull ARRAY of STRING DICT of all video games, delete test values
        
        let items = [
            ["imageName": "enemy.png", "title": "The Witcher 3", "genre": "adventure", "multiplayer": 1.0, "difficulty": 8.0, "competitive": 1.0, "popularity": 9.0],
            ["imageName": "jolie.png", "title": "Minecraft", "genre": "adventure", "multiplayer": 5.0, "difficulty": 3.0, "competitive": 1.0, "popularity": 9.0],
            ["imageName": "icon.png", "title": "Amnesia: The Dark Descent", "genre": "horror", "multiplayer": 1.0, "difficulty": 4.0, "competitive": 2.0, "popularity": 7.0]]
        
        videoGames = items
        
        interestsImage.image = UIImage(named: videoGames[0]["imageName"] as! String)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        ref.child("42069").child("preference").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value == nil {
                self.ref.child("42069").child("preference").setValue(self.defaultPreferences)
            }
        })
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {

        

        if let swipeGesture = gesture as? UISwipeGestureRecognizer {

            switch swipeGesture.direction {
            case .right:
                print("Swiped right")
                let rand = Int.random(in: 0..<videoGames.count)
                interestsImage.image = UIImage(named: self.videoGames[rand]["imageName"] as! String)
                
                ref.child("42069").child("preference").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    let values = snapshot.value as! NSDictionary
                    let curVideoGame = self.videoGames[rand]
                    let totalIdeasSeen: Double! = (values["totalIdeasSeen"] as? Double)! + 1
                    
                    let genre: String! = curVideoGame["genre"] as? String
                    let storesGenres: [String:Int]! = values["genres"] as? [String:Int]
                    let storedGenre: Int! = storesGenres[genre]
                    
                    self.recalculateValuesSendToDatabase(totalIdeasSeen: totalIdeasSeen, storedValue: values["difficulty"] as? Double ?? 5, newValue: curVideoGame["difficulty"] as? Double ?? 5, catagory: "difficulty")
                    self.recalculateValuesSendToDatabase(totalIdeasSeen: totalIdeasSeen, storedValue: values["multiplayer"] as? Double ?? 5, newValue: curVideoGame["multiplayer"] as? Double ?? 5, catagory: "multiplayer")
                    self.recalculateValuesSendToDatabase(totalIdeasSeen: totalIdeasSeen, storedValue: values["popularity"] as? Double ?? 5, newValue: curVideoGame["popularity"] as? Double ?? 5, catagory: "popularity")
                    self.recalculateValuesSendToDatabase(totalIdeasSeen: totalIdeasSeen, storedValue: values["competitive"] as? Double ?? 5, newValue: curVideoGame["competitive"] as? Double ?? 5, catagory: "competitive")
                    
                    self.ref.child("42069").child("preference").child("genres").updateChildValues([genre!: storedGenre + 1])
                    
                    self.ref.child("42069").child("preference").updateChildValues(["totalIdeasSeen": totalIdeasSeen!])
                })
            case .left:
                print("Swiped left")
                let rand = Int.random(in: 0..<videoGames.count)
                interestsImage.image = UIImage(named: self.videoGames[rand]["imageName"] as! String)
            default:
                break
            }
        }
    }
    
    func recalculateValuesSendToDatabase(totalIdeasSeen: Double, storedValue: Double, newValue: Double, catagory: String) {
        let recalculatedValue = ((newValue - storedValue) / totalIdeasSeen) + storedValue
        self.ref.child("42069").child("preference").updateChildValues([catagory: recalculatedValue])
    }
}
