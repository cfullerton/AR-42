//
//  utils.swift
//  AR 42
//
//  Created by Conner Fullerton on 8/1/21.
//

import Foundation

public class Utils {
    func genDems() -> [[Int]] {
        var dominoDems: [[Int]] = []
        var suit = 0, off = 0
        while suit < 7 {
            
            if off <= suit {
                dominoDems.append([suit,off])
                off += 1
            }else{
                suit += 1
                off = 0
            }
        }
        return dominoDems
    }
    
    func initPos(index:Int) -> [Float] {
        var x = Float(index % 3)
        var z = Float(index / 3)
        x = x * 0.4
        z = z * 0.2
        z -= 2
        if (index > 6) {
            //z += 0.3
        }
        if (index > 20){
            z += 0.3
        }
        if (index > 6 && index < 14){
            if [9,12].contains(index){
                x += 0.2
            }
            x += 0.9
            z += 0.2
        }
        if (index > 13 && index < 21){
            if [14,17,20].contains(index){
                x -= 0.2
            }
            x -= 0.7
            x -= x * 0.2
        }
        return [x,z]
    }
    
    func whoPlayedDomino(players:[Player],index:Int) -> Int {
        var playerIndex = 4
        for player in players {
            if player.holdingDominos.contains(index){
                playerIndex = players.firstIndex{$0 === player}!
            }
        }
        return playerIndex
    }
    func partnerIndex(playerIndex:Int) -> Int{
        var partner = 0
        if playerIndex == 0{
            partner = 2
        } else if playerIndex == 1{
            partner = 3
        } else if playerIndex == 2{
            partner = 0
        } else if playerIndex == 3{
            partner = 1
        }
        return partner
    }
    func partnerWinning(playerIndex:Int,gs:GameState,dominos:[Domino],utils:Utils,players:[Player]) -> Bool {
        var trumpPlayed = false
        var highestTrump = 0
        var higestTrumpUser = 4 //above the index of users
        let leadSuit = dominos[gs.dominosLayed[0]].values.max()
        var highestFollow = 0
        var highestFollowerIndex = 0
        var partnerWinning = false
        var topTrumpIsHighest = false
        let partner = partnerIndex(playerIndex: playerIndex)
        for index in gs.dominosLayed {
            //check for trump dominos played
            if dominos[index].isTrump(gs: gs){
                trumpPlayed = true
                var offIndex = 0
                if dominos[index].isDouble() {
                    highestTrump = 7
                    higestTrumpUser = utils.whoPlayedDomino(players: players,index: index)
                    topTrumpIsHighest = true
                } else {
                    if dominos[index].values[0] == gs.trump{
                        offIndex = 1
                    }
                    if dominos[index].values[offIndex] >= highestTrump {
                        highestTrump = dominos[index].values[offIndex]
                        higestTrumpUser = utils.whoPlayedDomino(players: players,index: index)
                        if dominos[index].isHighestRemainingTrump(gs: gs, dominos: dominos){
                            topTrumpIsHighest = true
                        }
                    }
                }
            } else {
                if dominos[index].values.contains(leadSuit!){
                    var offIndex = 0
                    if dominos[index].values[0] == leadSuit && dominos[index].values[1] == leadSuit {
                        highestFollow = 7
                        highestFollowerIndex = utils.whoPlayedDomino(players: players,index: index)
                    } else {
                        if dominos[index].values[0] == leadSuit{
                            offIndex = 1
                        }
                        if dominos[index].values[offIndex] >= highestFollow {
                            highestFollow = dominos[index].values[offIndex]
                            highestFollowerIndex = utils.whoPlayedDomino(players: players,index: index)
                        }
                    }
                }
            }
        }
        if trumpPlayed {
            if higestTrumpUser == partner {
                if gs.dominosLayed.count > 2 || topTrumpIsHighest {
                    partnerWinning = true
                }
            }
        } else {
            if highestFollowerIndex == partner && gs.dominosLayed.count > 2 {
                partnerWinning = true
            }
        }
        return partnerWinning // could add more logic like who followed suit etc
    }
}
