//
//  gameState.swift
//  AR 42
//
//  Created by Conner Fullerton on 8/2/21.
//

import Foundation

class GameState {
    var playerBid = 0
    var bid = 0
    var bidwinner = 0
    var trump = 7
    var startingPlayer = 0
    var bids: [[Int]] = []
    var dominosLayed: [Int] = []
    var currentSuit = 0
    var usScore = 0
    var ThemScore = 0
    var whosFirst = 0
    var usMarks = 0
    var themMarks = 0
    func reset() {
        playerBid = 0
        bid = 0
        bidwinner = 0
        trump = 7
        startingPlayer = 0
        bids = []
        dominosLayed = []
        currentSuit = 0
        usScore = 0
        ThemScore = 0
        if whosFirst == 3 {
            whosFirst = 0
        } else {
            whosFirst += 1
        }
    }
}
