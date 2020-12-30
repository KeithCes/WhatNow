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
    
    var defaultPreferences = DefaultPreferencesUser.defaultPreferences
    
    var pastUserPreferences: NSDictionary = [:]
    var curInterest: [String:Any] = [:]
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
            self.curInterest = value?.allValues.randomElement() as! [String : Any]
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
                    self.setUserPreferences()
                    //grabs the next random video game
                    let value = snapshot.value as? NSDictionary
                    self.curInterest = value?.allValues.randomElement() as! [String : Any]
                    self.getAndUpdateValuesAndImage()
                })
                
                
            case .left:
                print("Swiped left")
                
                self.typeOfInterest = pickInterestType()
                
                ref.child(self.typeOfInterest).observeSingleEvent(of: .value, with: { (snapshot) in
                    //grabs the next random video game
                    let value = snapshot.value as? NSDictionary
                    self.curInterest = value?.allValues.randomElement() as! [String : Any]
                    self.getAndUpdateValuesAndImage()
                })
                
                
            default:
                break
            }
        }
    }
    
    //gets user preferences, if empty populate with default
    //gets image from backend and sets based on curInterest:
    //sets global values based on curInterest:
    func getAndUpdateValuesAndImage() {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        self.ref.child("users").child(self.userID).child("preferences").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value == nil {
                self.ref.child("users").child(self.userID).child("preferences").setValue(self.defaultPreferences)
            }
            
            //gets image from backend and sets
            let imageName = self.curInterest["imageName"] as! String
            let imageRef = storageRef.child("images/" + self.typeOfInterest + "/" + imageName)
            imageRef.getData(maxSize: 1 * 69696 * 69696) { data, error  in
                let image = UIImage(data: data!)
                self.interestsImage.image = image
                self.interestsLabel.text = self.curInterest["title"] as? String
            }
            
            //sets values to whats game has been pulled
            self.ref.child("users").child(self.userID).child("preferences").observeSingleEvent(of: .value, with: { (snapshot) in
                self.pastUserPreferences = snapshot.value as! NSDictionary
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
        self.totalIdeasSeen = (self.pastUserPreferences["totalIdeasSeen"] as? Double)! + 1
        
        self.genre = self.curInterest["genre"] as? String
        self.storesGenres = self.pastUserPreferences["genre"] as? [String:Int]
        self.storedGenre = self.storesGenres[self.genre]
    }
    
    //calls recalculateValuesSendToDatabase() and sends out the result
    func setUserPreferences() {
        self.curUserPreferences["totalIdeasSeen"] = (self.pastUserPreferences["totalIdeasSeen"] as? Double)! + 1
                
        setUnNestedPreference(preference: "difficulty")
        setUnNestedPreference(preference: "multiplayer")
        setUnNestedPreference(preference: "popularity")
        setUnNestedPreference(preference: "competitive")
        setUnNestedPreference(preference: "radicalness")
        setNestedPreference(nestedPreference: "genre")
        setNestedPreference(nestedPreference: "era")
            
        self.ref.child("users").child(self.userID).child("preferences").setValue(self.curUserPreferences)
    }
    
    func setUnNestedPreference(preference: String) {
        if self.curInterest[preference] != nil && pastUserPreferences[preference] != nil {
            self.curUserPreferences[preference] = self.recalculateValuesSendToDatabase(totalIdeasSeen: self.totalIdeasSeen, storedValue: (self.pastUserPreferences[preference] as? Double)!, newValue: (self.curInterest[preference] as? Double)!)
        }
        else {
            self.curUserPreferences[preference] = self.pastUserPreferences[preference]
        }
    }
    
    func setNestedPreference(nestedPreference: String) {
        if self.curInterest[nestedPreference] != nil && pastUserPreferences[nestedPreference] != nil {
            let curGenre: String! = self.curInterest[nestedPreference] as? String
            var storedGenres: [String:Int]! = self.pastUserPreferences[nestedPreference] as? [String:Int]
            storedGenres[curGenre] = storedGenres[curGenre]! + 1
            self.curUserPreferences[nestedPreference] = storedGenres
        }
        else {
            self.curUserPreferences[nestedPreference] = self.pastUserPreferences[nestedPreference]
        }
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
