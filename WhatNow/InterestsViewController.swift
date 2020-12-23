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
    
    var values: NSDictionary = [:]
    var curVideoGame: [String:Any] = [:]
    var totalIdeasSeen: Double! = nil
    
    var genre: String! = nil
    var storesGenres: [String:Int]! = nil
    var storedGenre: Int! = nil
    
    var rand: Int! = nil
    
    var curUserPreferences =
    [
        "totalIdeasSeen": 1,
        "difficulty": 5,
        "popularity": 5,
        "multiplayer": 5,
        "competitive": 5,
        "genres":
        [
            "adventure": 0,
            "action": 0,
            "horror": 0,
        ],
    ] as [String : Any]
    
    override func viewDidLoad() {
        
        ref = Database.database().reference()
        
        //TODO: connect to firebase and pull ARRAY of STRING DICT of all video games, delete test values
        
        let items = [
            ["imageName": "enemy.png", "title": "The Witcher 3", "genre": "adventure", "multiplayer": 1.0, "difficulty": 8.0, "competitive": 1.0, "popularity": 9.0],
            ["imageName": "jolie.png", "title": "Minecraft", "genre": "adventure", "multiplayer": 5.0, "difficulty": 3.0, "competitive": 1.0, "popularity": 9.0],
            ["imageName": "icon.png", "title": "Amnesia: The Dark Descent", "genre": "horror", "multiplayer": 1.0, "difficulty": 4.0, "competitive": 2.0, "popularity": 7.0]]
        
        videoGames = items
        
        ref.child("42069").child("preference").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value == nil {
                self.ref.child("42069").child("preference").setValue(self.defaultPreferences)
            }
            self.rand = Int.random(in: 0..<self.videoGames.count)
            self.interestsImage.image = UIImage(named: self.videoGames[self.rand]["imageName"] as! String)
            self.ref.child("42069").child("preference").observeSingleEvent(of: .value, with: { (snapshot) in
                
                self.values = snapshot.value as! NSDictionary
                
                self.setVideoGameValues()
            })
        })
        
        
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {

        

        if let swipeGesture = gesture as? UISwipeGestureRecognizer {

            switch swipeGesture.direction {
            case .right:
                print("Swiped right")
                
                rand = Int.random(in: 0..<videoGames.count)
                interestsImage.image = UIImage(named: self.videoGames[rand]["imageName"] as! String)
                
                ref.child("42069").child("preference").observeSingleEvent(of: .value, with: { (snapshot) in
                    
//                    self.ref.child("42069").child("preference").child("genres").updateChildValues([self.genre!: self.storedGenre + 1])
//
                    
                    DispatchQueue.main.async {
                    
                        self.curUserPreferences["totalIdeasSeen"] = (self.values["totalIdeasSeen"] as? Double)! + 1
                        
                        self.curUserPreferences["difficulty"] = self.recalculateValuesSendToDatabase(totalIdeasSeen: self.totalIdeasSeen, storedValue: self.values["difficulty"] as? Double ?? 5, newValue: self.curVideoGame["difficulty"] as? Double ?? 5)
                        self.curUserPreferences["multiplayer"] = self.recalculateValuesSendToDatabase(totalIdeasSeen: self.totalIdeasSeen, storedValue: self.values["multiplayer"] as? Double ?? 5, newValue: self.curVideoGame["multiplayer"] as? Double ?? 5)
                        self.curUserPreferences["popularity"] = self.recalculateValuesSendToDatabase(totalIdeasSeen: self.totalIdeasSeen, storedValue: self.values["popularity"] as? Double ?? 5, newValue: self.curVideoGame["popularity"] as? Double ?? 5)
                        self.curUserPreferences["competitive"] = self.recalculateValuesSendToDatabase(totalIdeasSeen: self.totalIdeasSeen, storedValue: self.values["competitive"] as? Double ?? 5, newValue: self.curVideoGame["competitive"] as? Double ?? 5)
                            
                        self.ref.child("42069").child("preference").setValue(self.curUserPreferences)
                    }
                    
                    self.values = snapshot.value as! NSDictionary
                    
                    self.setVideoGameValues()
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
    
    func recalculateValuesSendToDatabase(totalIdeasSeen: Double, storedValue: Double, newValue: Double) -> Double {
        let recalculatedValue = ((newValue - storedValue) / totalIdeasSeen) + storedValue
        return recalculatedValue
    }
    
    func setVideoGameValues() {
        self.curVideoGame = self.videoGames[self.rand]
        self.totalIdeasSeen = (self.values["totalIdeasSeen"] as? Double)! + 1
        
        self.genre = self.curVideoGame["genre"] as? String
        self.storesGenres = self.values["genres"] as? [String:Int]
        self.storedGenre = self.storesGenres[self.genre]
    }
}
