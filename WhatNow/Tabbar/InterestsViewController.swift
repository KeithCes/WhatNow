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
    
    var ref: DatabaseReference!
    
    var videoGames: [[String:Any]] = []
    
    var defaultPreferences = DefaultPreferencesUser.defaultPreferences
    
    var values: NSDictionary = [:]
    var curVideoGame: [String:Any] = [:]
    var totalIdeasSeen: Double! = nil
    
    var genre: String! = nil
    var storesGenres: [String:Int]! = nil
    var storedGenre: Int! = nil
    
    var curUserPreferences = DefaultPreferencesUser.defaultPreferences
    
    override func viewDidLoad() {
        
        ref = Database.database().reference()
        
        //gets list of all video games from backend
        ref.child("videogames").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.curVideoGame = value?.allValues.randomElement() as! [String : Any]
        })
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        //gets initial user preferences
        ref.child("42069").child("preference").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value == nil {
                self.ref.child("42069").child("preference").setValue(self.defaultPreferences)
            }
            
            //gets image from backend and sets
            let imageName = self.curVideoGame["imageName"] as! String
            let imageRef = storageRef.child("images/videogames/" + imageName)
            imageRef.getData(maxSize: 1 * 69696 * 69696) { data, error  in
                let image = UIImage(data: data!)
                self.interestsImage.image = image
            }
            
            //sets values to whats game has been pulled
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
                
                //TODO: add weighted randomness; items more related to user preferences get picked more often
                
                let storage = Storage.storage()
                let storageRef = storage.reference()
                
                //gets next image from backend and sets
                let imageName = self.curVideoGame["imageName"] as! String
                let imageRef = storageRef.child("images/videogames/" + imageName)
                imageRef.getData(maxSize: 1 * 69696 * 69696) { data, error  in
                    let image = UIImage(data: data!)
                    self.interestsImage.image = image
                }
                
                //gets list of all video games from backend
                ref.child("videogames").observeSingleEvent(of: .value, with: { (snapshot) in
                    let value = snapshot.value as? NSDictionary
                    self.curVideoGame = value?.allValues.randomElement() as! [String : Any]
                })
                
                //sets values to whats game has been pulled
                ref.child("42069").child("preference").observeSingleEvent(of: .value, with: { (snapshot) in
                    self.setVideoGameValues()
                    self.values = snapshot.value as! NSDictionary
                })
                
                
                self.setUserPreferencesVideoGames()
                
            case .left:
                print("Swiped left")
                let rand = Int.random(in: 0..<videoGames.count)
                interestsImage.image = UIImage(named: self.videoGames[rand]["imageName"] as! String)
            default:
                break
            }
        }
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
            
            
        self.ref.child("42069").child("preference").setValue(self.curUserPreferences)
    }
}
