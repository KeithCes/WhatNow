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
    @IBOutlet weak var interestsCard: UIView!
    
    var ref: DatabaseReference!
    
    var typeOfInterest: String = ""
    
    var pastUserPreferences: NSDictionary = [:]
    var curInterest: [String:Any] = [:]
    var totalInterestsSeen: Double! = nil
    
    let userID = Auth.auth().currentUser!.uid
    
    var curUserPreferences = DefaultPreferencesUser.defaultPreferences
    
    override func viewDidLoad() {
        
        self.view.backgroundColor = CustomColors.grayDark
        self.interestsCard.backgroundColor = CustomColors.grayLight
        
        ref = Database.database().reference()

        self.ref.child("users").child(self.userID).child("preferences").observeSingleEvent(of: .value, with: { (snapshot) in
            let allPreferences = snapshot.value as? NSDictionary
            //picks type of interest from all interests
            self.typeOfInterest = self.pickInterestType(allInterests: allPreferences?["interests"] as! [String : Int])
            
            //grabs all interests of chosen type from backend
            self.ref.child("allInterests").child(self.typeOfInterest).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                
                //choose random interest to use
                self.curInterest = self.addKickerToPreferences(userPreferences: allPreferences as! [String : Any], interests: value as! [String : [String:Any]])
                //update
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
                
                
                //animation
                let fromPt = CGPoint(x: 0.0, y: 0)
                let toPt = CGPoint(x: 2500.0, y: 0)
                let movement = CABasicAnimation(keyPath: "position")
                movement.isAdditive = true
                movement.fromValue = NSValue(cgPoint: fromPt)
                movement.toValue = NSValue(cgPoint: toPt)
                movement.duration = 3
                interestsCard.layer.add(movement, forKey: "move")
                
                interestsCard.rotate()
                interestsCard.fadeOut()
                
                
                //sets the interests preference based on the previous one before we call the next one
                var storedInterests: [String:Int]! = self.pastUserPreferences["interests"] as? [String:Int]
                storedInterests[self.typeOfInterest] = storedInterests[self.typeOfInterest]! + 1
                self.curUserPreferences["interests"] = storedInterests
                
                //calls the next interest
                ref.child("users").child(self.userID).child("preferences").observeSingleEvent(of: .value, with: { (snapshot) in
                    let allPreferences = snapshot.value as? NSDictionary
                    self.typeOfInterest = self.pickInterestType(allInterests: allPreferences?["interests"] as! [String : Int])
                
                    self.ref.child("allInterests").child(self.typeOfInterest).observeSingleEvent(of: .value, with: { (snapshot) in
                        //sets and updates user preferences based on the last thing swiped
                        self.setUserPreferences()
                        //grabs the next random video game
                        let value = snapshot.value as? NSDictionary
                        self.curInterest = value?.allValues.randomElement() as! [String : Any]
                        self.getAndUpdateValuesAndImage()
                        
                        self.interestsCard.layer.removeAllAnimations()
                        
                        self.interestsCard.fadeIn()
                    })
                })
                
                
            case .left:
                print("Swiped left")
                
                //animation
                let fromPt = CGPoint(x: 0.0, y: 0)
                let toPt = CGPoint(x: -2500.0, y: 0)
                let movement = CABasicAnimation(keyPath: "position")
                movement.isAdditive = true
                movement.fromValue = NSValue(cgPoint: fromPt)
                movement.toValue = NSValue(cgPoint: toPt)
                movement.duration = 3
                interestsCard.layer.add(movement, forKey: "move")
                
                interestsCard.rotateCounter()
                interestsCard.fadeOut()
                
                ref.child("users").child(self.userID).child("preferences").observeSingleEvent(of: .value, with: { (snapshot) in
                    let allPreferences = snapshot.value as? NSDictionary
                    self.typeOfInterest = self.pickInterestType(allInterests: allPreferences?["interests"] as! [String : Int])
                    
                    self.ref.child("allInterests").child(self.typeOfInterest).observeSingleEvent(of: .value, with: { (snapshot) in
                        let value = snapshot.value as? NSDictionary
                        self.curInterest = value?.allValues.randomElement() as! [String : Any]
                        self.getAndUpdateValuesAndImage()
                        
                        self.interestsCard.layer.removeAllAnimations()
                        
                        self.interestsCard.fadeIn()
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
            self.totalInterestsSeen = (self.pastUserPreferences["totalInterestsSeen"] as! Double) + 1.0
        })
    }
    
    //averages weighted the new values
    func recalculateValuesSendToDatabase(totalInterestsSeen: Double, storedValue: Double, newValue: Double) -> Double {
        let recalculatedValue = ((newValue - storedValue) / totalInterestsSeen) + storedValue
        return recalculatedValue
    }
    
    //calls recalculateValuesSendToDatabase() and sends out the result
    func setUserPreferences() {
        self.curUserPreferences["totalInterestsSeen"] = (self.pastUserPreferences["totalInterestsSeen"] as! Double) + 1.0
                
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
            self.curUserPreferences[preference] = self.recalculateValuesSendToDatabase(totalInterestsSeen: self.totalInterestsSeen, storedValue: self.pastUserPreferences[preference] as! Double, newValue: self.curInterest[preference] as! Double)
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
        
        return typesOfInterests[rand]
    }
    
    func addKickerToPreferences(userPreferences: [String:Any], interests: [String:[String:Any]]) -> [String : Any] {
        //TODO: remove all force unwraps and optimize shitty loops, hacky ass code below
        var kickedPreferences: [String:Double] = [:]
        var kickedNestedPreferences: [String:[String:Double]] = [:]
        for preference in userPreferences {
            if let _ = preference.value as? Double {
                //TODO: rarely make random go completely out of range to suggest stuff out of comfort zone
                let rand = Double.random(in: -2.0...2.0)
                kickedPreferences[preference.key] = preference.value as! Double + rand
            }
            else if let _ = preference.value as? [String:Double] {
                let allPreferences: [String:Double] = preference.value as! [String : Double]
                var totalProperties: Double = 0
                kickedNestedPreferences[preference.key] = preference.value as? [String : Double]
                for property in allPreferences {
                    totalProperties += property.value
                }
                for property in allPreferences {
                    //TODO: make nesteds with 0 in properties = highest weight instead of flat 1 (add scaling)
                    let rand = Double.random(in: -0.0...1.5)
                    let newPropertyValue = (1 - (property.value / totalProperties)) + rand
                    kickedNestedPreferences[preference.key]![property.key] = newPropertyValue
                }
            }
            else {
                
            }
        }
        var allDifferences: [Double] = []
        var allDifferencesTitles: [String] = []
        for interest in interests {
            let interestName = interest.key
            let interestData = interest.value
            var kickedDifference: Double = 0
            for interestProperty in interestData {
                //calcs difference for each interest property vs kicked preferences proptery
                for preferenceProperty in kickedPreferences {
                    if interestProperty.key == preferenceProperty.key {
                        let curDifference: Double = abs(interestProperty.value as! Double - preferenceProperty.value)
                        kickedDifference += curDifference
                    }
                }
                //calcs difference for each nested interest property vs kicked preferences proptery
                if kickedNestedPreferences[interestProperty.key] != nil {
                    for nestedPreferenceProperty in kickedNestedPreferences[interestProperty.key]! {
                        if interestProperty.value as! String == nestedPreferenceProperty.key {
                            let curDifference: Double = abs(nestedPreferenceProperty.value)
                            kickedDifference += curDifference
                        }
                    }
                }
            }
            allDifferences.append(kickedDifference)
            allDifferencesTitles.append(interestName)
        }
        let minDiff = allDifferences.min()
        let indMinDiff = allDifferences.firstIndex(of: minDiff!)
        return interests[allDifferencesTitles[indMinDiff ?? 0]]!
    }
}
