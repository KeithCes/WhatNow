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
import FirebaseStorage

class InterestsViewController: UIViewController {
    
    @IBOutlet weak var interestsImage: UIImageView!
    @IBOutlet weak var interestsLabel: UILabel!
    
    var ref: DatabaseReference!
    
    var typeOfInterest: String = ""
    var videoGames: [[String:Any]] = []
    
    var defaultPreferences = DefaultPreferencesUser.defaultPreferences
    
    var values: NSDictionary = [:]
    var curVideoGame: [String:Any] = [:]
    var totalIdeasSeen: Double! = nil
    
    var genre: String! = nil
    var storesGenres: [String:Int]! = nil
    var storedGenre: Int! = nil
    
    let userID = Auth.auth().currentUser!.uid
    
    var curUserPreferences = DefaultPreferencesUser.defaultPreferences
    
    //TODO: clean up ! force unwrapping
    
    override func viewDidLoad() {
        
        ref = Database.database().reference()
        
        self.typeOfInterest = pickInterestType()
        
        
        ref.child(self.typeOfInterest).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.curVideoGame = value?.allValues.randomElement() as! [String : Any]
            self.getAndUpdateValuesAndImage()
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
                
                self.typeOfInterest = pickInterestType()
                
                //TODO: add weighted randomness; items more related to user preferences get picked more often
                ref.child(self.typeOfInterest).observeSingleEvent(of: .value, with: { (snapshot) in
                    //sets and updates user preferences based on the last thing swiped
                    self.setUserPreferencesVideoGames()
                    //grabs the next random video game
                    let value = snapshot.value as? NSDictionary
                    self.curVideoGame = value?.allValues.randomElement() as! [String : Any]
                    self.getAndUpdateValuesAndImage()
                })
                
                
            case .left:
                print("Swiped left")
                
                self.typeOfInterest = pickInterestType()
                
                ref.child(self.typeOfInterest).observeSingleEvent(of: .value, with: { (snapshot) in
                    //grabs the next random video game
                    let value = snapshot.value as? NSDictionary
                    self.curVideoGame = value?.allValues.randomElement() as! [String : Any]
                    self.getAndUpdateValuesAndImage()
                })
                
                
            default:
                break
            }
        }
    }
    
    //gets user preferences, if empty populate with default
    //gets image from backend and sets based on curVideoGame
    //sets global values based on curVideoGame
    func getAndUpdateValuesAndImage() {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        self.ref.child("users").child(self.userID).child("preferences").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value == nil {
                self.ref.child("users").child(self.userID).child("preferences").setValue(self.defaultPreferences)
            }
            
            //gets image from backend and sets
            let imageName = self.curVideoGame["imageName"] as! String
            let imageRef = storageRef.child("images/" + self.typeOfInterest + "/" + imageName)
            imageRef.getData(maxSize: 1 * 69696 * 69696) { data, error  in
                let image = UIImage(data: data!)
                self.interestsImage.image = image
                self.interestsLabel.text = self.curVideoGame["title"] as? String
            }
            
            //sets values to whats game has been pulled
            self.ref.child("users").child(self.userID).child("preferences").observeSingleEvent(of: .value, with: { (snapshot) in
                self.values = snapshot.value as! NSDictionary
                self.setVideoGameValues()
            })
        })
    }
    
    //averages weighted the new values
    func recalculateValuesSendToDatabase(totalIdeasSeen: Double, storedValue: Double, newValue: Double) -> Double {
        let recalculatedValue = ((newValue - storedValue) / totalIdeasSeen) + storedValue
        return recalculatedValue
    }
    
    //sets the globals to be the values that are pulled
    func setVideoGameValues() {
        self.totalIdeasSeen = (self.values["totalIdeasSeen"] as? Double)! + 1
        
        self.genre = self.curVideoGame["genre"] as? String
        self.storesGenres = self.values["genres"] as? [String:Int]
        self.storedGenre = self.storesGenres[self.genre]
    }
    
    //calls recalculateValuesSendToDatabase() and sends out the result
    func setUserPreferencesVideoGames() {
        self.curUserPreferences["totalIdeasSeen"] = (self.values["totalIdeasSeen"] as? Double)! + 1
            
        self.curUserPreferences["difficulty"] = self.recalculateValuesSendToDatabase(totalIdeasSeen: self.totalIdeasSeen, storedValue: self.values["difficulty"] as? Double ?? 5, newValue: self.curVideoGame["difficulty"] as? Double ?? 5)
        self.curUserPreferences["multiplayer"] = self.recalculateValuesSendToDatabase(totalIdeasSeen: self.totalIdeasSeen, storedValue: self.values["multiplayer"] as? Double ?? 5, newValue: self.curVideoGame["multiplayer"] as? Double ?? 5)
        self.curUserPreferences["popularity"] = self.recalculateValuesSendToDatabase(totalIdeasSeen: self.totalIdeasSeen, storedValue: self.values["popularity"] as? Double ?? 5, newValue: self.curVideoGame["popularity"] as? Double ?? 5)
        self.curUserPreferences["competitive"] = self.recalculateValuesSendToDatabase(totalIdeasSeen: self.totalIdeasSeen, storedValue: self.values["competitive"] as? Double ?? 5, newValue: self.curVideoGame["competitive"] as? Double ?? 5)
                
        let curGenre: String! = self.curVideoGame["genre"] as? String
        var storedGenres: [String:Int]! = self.values["genres"] as? [String:Int]
        storedGenres[curGenre] = storedGenres[curGenre]! + 1
        self.curUserPreferences["genres"] = storedGenres
            
            
        self.ref.child("users").child(self.userID).child("preferences").setValue(self.curUserPreferences)
    }
    
    func pickInterestType() -> String{
        let typesOfInterests = 2 //video games, movies
        let rand = Int.random(in: 0..<typesOfInterests)
        switch (rand) {
        case 0:
            return "videogames"
        case 1:
            return "movies"
        default:
            return "videogames"
        }
    }
}
