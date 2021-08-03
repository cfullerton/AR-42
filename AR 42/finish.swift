//
//  findWinner.swift
//  AR 42
//
//  Created by Conner Fullerton on 8/2/21.
//

import Foundation
import RealityKit
import SceneKit.ModelIO
class Finish {
    var roundScore = 0
    var roundWinner = 0
    var domsPlayed = ""
    
    func checkPoints(gs:GameState) -> Bool {
        var setScore = 0
        if gs.bidwinner == 0 || gs.bidwinner == 2 {
            setScore = gs.ThemScore
        }else {
            setScore = gs.usScore
        }
        return gs.usScore + gs.ThemScore == 42 || 42 - setScore < gs.bid || gs.usScore >= gs.bid || gs.ThemScore >= gs.bid
    }
    func round(gs:GameState,dominos:[Domino],utils:Utils,players:[Player]) {
        var score = 1
        var trumpPlayed = false
        var highestTrump = 0
        var higestTrumpUser = 4 //above the index of users
        let leadSuit = dominos[gs.dominosLayed[0]].values.max()
        var highestFollow = 0
        var highestFollowerIndex = 0
        var playedDominoText = ""
        for index in gs.dominosLayed {
            playedDominoText += dominos[index].name.dropFirst(1) + " "
            // check for points dominos
            if dominos[index].values[0] + dominos[index].values[1] == 5 || dominos[index].values[0] + dominos[index].values[1] == 10 {
                score += dominos[index].values[0] + dominos[index].values[1]
            }
            
            //check for trump dominos played
            if dominos[index].values.contains(gs.trump){
                trumpPlayed = true
                var offIndex = 0
                // checks for double trump
                if dominos[index].values[0] == gs.trump && dominos[index].values[1] == gs.trump {
                    highestTrump = 7
                    higestTrumpUser = utils.whoPlayedDomino(players: players,index: index)
                } else {
                    if dominos[index].values[0] == gs.trump{
                        offIndex = 1
                    }
                    if dominos[index].values[offIndex] >= highestTrump {
                        highestTrump = dominos[index].values[offIndex]
                        higestTrumpUser = utils.whoPlayedDomino(players: players,index: index)
                    }
                }
            } else {
                if dominos[index].values.contains(leadSuit!){
                    var offIndex = 0
                    if dominos[index].values[0] == leadSuit && dominos[index].values[1] == leadSuit {
                        highestFollow = 7
                        //todo: change to a playerIsHoldingDomino function
                        highestFollowerIndex = utils.whoPlayedDomino(players: players,index: index)
                    } else {
                        if dominos[index].values[0] == leadSuit{
                            offIndex = 1
                        }
                        if dominos[index].values[offIndex] >= highestFollow {
                            highestFollow = dominos[index].values[offIndex]
                            //todo: change to a playerIsHoldingDomino function
                            highestFollowerIndex = utils.whoPlayedDomino(players: players,index: index)
                        }
                    }
                }
            }
        }
        if trumpPlayed {
            roundWinner = higestTrumpUser
        } else {
            roundWinner = highestFollowerIndex
        }
        domsPlayed = playedDominoText
        roundScore = score
    }
}
