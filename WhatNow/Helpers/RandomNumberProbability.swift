//
//  RandomNumberProbability.swift
//  WhatNow
//
//  Created by Keith C on 12/30/20.
//

import Foundation

//ripped from stackoverflow (im takin that)
class RandomNumberProbability {
    static func randomNumber(probabilities: [Double]) -> Int {
        
        for element in probabilities {
            if element.isNaN {
                return 0
            }
        }
        
        // Sum of all probabilities (so that we don't have to require that the sum is 1.0):
        let sum = probabilities.reduce(0, +)
        // Random number in the range 0.0 <= rnd < sum :
        let rnd = Double.random(in: 0.0 ..< sum)
        // Find the first interval of accumulated probabilities into which `rnd` falls:
        var accum = 0.0
        for (i, p) in probabilities.enumerated() {
            accum += p
            if rnd < accum {
                return i
            }
        }
        // This point might be reached due to floating point inaccuracies:
        return (probabilities.count - 1)
    }
}
