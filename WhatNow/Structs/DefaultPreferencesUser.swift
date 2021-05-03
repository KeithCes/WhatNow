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
        "totalInterestsSeen": 1,
        "difficulty": 5,
        "popularity": 5,
        "multiplayer": 5,
        "competitive": 5,
        "radicalness": 5,
        "genre":
        [
            "adventure": 0,
            "action": 0,
            "horror": 0,
            "sci-fi": 0,
            "drama": 0,
            "puzzle": 0,
            "platformer": 0,
            "mmorpg": 0,
            "rpg": 0,
            "fighting": 0,
            "rts": 0,
            "strategy": 0,
            "sports": 0,
            "racing": 0,
            "party": 0,
            "battle-royale": 0,
            "fps": 0
        ],
        "era":
        [
            "pre30s": 0,
            "40s": 0,
            "50s": 0,
            "60s": 0,
            "70s": 0,
            "80s": 0,
            "90s": 0,
            "00s": 0,
            "10s": 0,
            "modern": 0
        ],
        "interests":
        [
            "videogames": 10,
            "movies": 10
        ]
    ] as [String : Any]
}
