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
import FirebaseUI

class InterestsViewController: UIViewController {
    
    @IBOutlet weak var interestsImage: UIImageView!
    @IBOutlet weak var interestsLabel: UILabel!
    
    var ref: DatabaseReference!
    
    var typeOfInterest: String = ""
    
    var pastUserPreferences: NSDictionary = [:]
    var curInterest: [String:Any] = [:]
    var totalIdeasSeen: Double! = nil
    
    let userID = Auth.auth().currentUser!.uid
    
    var curUserPreferences = DefaultPreferencesUser.defaultPreferences
    
    //TODO: rename totalIdeasSeen to totalInterestsSeen
    
    override func viewDidLoad() {
        
        ref = Database.database().reference()

        self.ref.child("users").child(self.userID).child("preferences").observeSingleEvent(of: .value, with: { (snapshot) in
            let allPreferences = snapshot.value as? NSDictionary
            self.typeOfInterest = self.pickInterestType(allInterests: allPreferences?["interests"] as! [String : Int])
            
            self.ref.child(self.typeOfInterest).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                self.curInterest = value?.allValues.randomElement() as! [String : Any]
                self.getAndUpdateValuesAndImage()
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
                
                //sets the interests preference based on the previous one before we call the next one
                var storedInterests: [String:Int]! = self.pastUserPreferences["interests"] as? [String:Int]
                storedInterests[self.typeOfInterest] = storedInterests[self.typeOfInterest]! + 1
                self.curUserPreferences["interests"] = storedInterests
                
                //calls the next interest
                ref.child("users").child(self.userID).child("preferences").observeSingleEvent(of: .value, with: { (snapshot) in
                    let allPreferences = snapshot.value as? NSDictionary
                    self.typeOfInterest = self.pickInterestType(allInterests: allPreferences?["interests"] as! [String : Int])
                
                    //TODO: add weighted randomness; items more related to user preferences get picked more often
                    self.ref.child(self.typeOfInterest).observeSingleEvent(of: .value, with: { (snapshot) in
                        //sets and updates user preferences based on the last thing swiped
                        self.setUserPreferences()
                        //grabs the next random video game
                        let value = snapshot.value as? NSDictionary
                        self.curInterest = value?.allValues.randomElement() as! [String : Any]
                        self.getAndUpdateValuesAndImage()
                    })
                })
                
                
            case .left:
                print("Swiped left")
                
                ref.child("users").child(self.userID).child("preferences").observeSingleEvent(of: .value, with: { (snapshot) in
                    let allPreferences = snapshot.value as? NSDictionary
                    self.typeOfInterest = self.pickInterestType(allInterests: allPreferences?["interests"] as! [String : Int])
                    
                    self.ref.child(self.typeOfInterest).observeSingleEvent(of: .value, with: { (snapshot) in
                        let value = snapshot.value as? NSDictionary
                        self.curInterest = value?.allValues.randomElement() as! [String : Any]
                        self.getAndUpdateValuesAndImage()
                    })
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
        
        //gets image from backend and sets
        let imageName = self.curInterest["imageName"] as! String
        let imageRef = storageRef.child("images/" + self.typeOfInterest + "/" + imageName)
        let placeholderImage = UIImage(named: "blank")
        self.interestsImage.sd_setImage(with: imageRef, placeholderImage: placeholderImage)
        self.interestsLabel.text = self.curInterest["title"] as? String
            
        //sets values to whats game has been pulled
        self.ref.child("users").child(self.userID).child("preferences").observeSingleEvent(of: .value, with: { (snapshot) in
            self.pastUserPreferences = snapshot.value as! NSDictionary
            self.totalIdeasSeen = (self.pastUserPreferences["totalIdeasSeen"] as! Double) + 1.0
        })
    }
    
    //averages weighted the new values
    func recalculateValuesSendToDatabase(totalIdeasSeen: Double, storedValue: Double, newValue: Double) -> Double {
        let recalculatedValue = ((newValue - storedValue) / totalIdeasSeen) + storedValue
        return recalculatedValue
    }
    
    //calls recalculateValuesSendToDatabase() and sends out the result
    func setUserPreferences() {
        self.curUserPreferences["totalIdeasSeen"] = (self.pastUserPreferences["totalIdeasSeen"] as! Double) + 1.0
                
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
            self.curUserPreferences[preference] = self.recalculateValuesSendToDatabase(totalIdeasSeen: self.totalIdeasSeen, storedValue: self.pastUserPreferences[preference] as! Double, newValue: self.curInterest[preference] as! Double)
        }
        else {
            self.curUserPreferences[preference] = self.pastUserPreferences[preference]
        }
    }
    
    func setNestedPreference(nestedPreference: String) {
        if self.curInterest[nestedPreference] != nil && pastUserPreferences[nestedPreference] != nil {
            let curInterestName: String! = self.curInterest[nestedPreference] as? String
            var curNestedPreferences: [String:Int]! = self.pastUserPreferences[nestedPreference] as? [String:Int]
            curNestedPreferences[curInterestName] = curNestedPreferences[curInterestName]! + 1
            self.curUserPreferences[nestedPreference] = curNestedPreferences
        }
        else {
            self.curUserPreferences[nestedPreference] = self.pastUserPreferences[nestedPreference]
        }
    }
    
    func pickInterestType(allInterests: [String:Int]) -> String {
        var totalInterests: Double = 0
        var weightedInterests: [Double] = []
        var typesOfInterests: [String] = []
        
        for interests in allInterests {
            totalInterests += Double(interests.value)
        }
        for interests in allInterests {
            let interestsValue = Double(interests.value)
            weightedInterests.append(interestsValue / totalInterests)
            typesOfInterests.append(interests.key)
        }
        
        let rand = RandomNumberProbability.randomNumber(probabilities: weightedInterests)
        
        print(weightedInterests)
        print(rand)
        
        return typesOfInterests[rand]
    }
}
