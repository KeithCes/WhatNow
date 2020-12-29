//
//  DefaultPreferencesUser.swift
//  WhatNow
//
//  Created by Keith C on 12/22/20.
//

import Foundation

class DefaultPreferencesUser {
    static let defaultPreferences =
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
            "sci-fi": 0,
            "drama": 0
        ],
    ] as [String : Any]
}
