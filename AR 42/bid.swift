//
//  bid.swift
//  AR 42
//
//  Created by Conner Fullerton on 8/1/21.
//

import Foundation

public class BidDecision {
    var bidChoice = 1
    var trumpChoice = 7
    init(player:Player,dominos:[Domino], currentBid:Int) {
        var computerTrump = 7 // no trump
        var computerBid = 1
        var confidence = 0
        var doubles: [Int] = []
        var suitCount: [[Int]] = []
        for i in 0...6 {
            suitCount.append([i,0])
        }
        for dominoIndex in player.holdingDominos{
            let dominoValues = dominos[dominoIndex].name.split(separator: "_").compactMap { Int($0) }
            if dominoValues[0] == dominoValues[1] {
                doubles.append(dominoValues[0])
            }
            for i in 0...6 {
                if dominoValues.contains(suitCount[i][0]) {
                    suitCount[i][1] += 1
                }
            }
        }
        var bestSuit = [0,0]
        var bestSuitCount = 0
        for suit in suitCount {
            if suit[1] > bestSuitCount {
                bestSuit = suit
                bestSuitCount = suit[1]
            }
        }
        if doubles.contains(bestSuit[0]) { // if they have the double of their best
            confidence += 20
        }
        if bestSuitCount > 3 { // if they have at least 4 of the same suit
            confidence += 20
        }
        if bestSuit[0] > 3 { // if it is a a high suit
            confidence += 10
        }
        if bestSuit[1] + doubles.count > 5 { // they only have one off domino
            confidence += 30
        }
        if doubles.contains(6){
            confidence += 10
        }
        if doubles.contains(5) {
            confidence += 10
        }
        if doubles.count > 4 { // 4 doubles
            confidence += 30
        }
        if doubles.count > 6 { // all doubles
            confidence += 100
            computerTrump = 7
        } else if doubles.count > 4 && bestSuit[1] < 4 {
                computerTrump = 7
        } else {
            computerTrump = bestSuit[0]
        }
        
        if confidence > 100 {
            // todo: what if someone already bid 42
            computerBid = 42
        } else if confidence > 50 {
            if currentBid >= 30 {
                computerBid = currentBid + 1
            }else {
                computerBid = 30
            }
        }else{
            computerBid = 1
        }
        bidChoice = computerBid
        trumpChoice = computerTrump
    }
}
