//
//  computerPlay.swift
//  AR 42
//
//  Created by Conner Fullerton on 8/3/21.
//

import Foundation
import RealityKit
import SceneKit.ModelIO
class ComputerPlay {
    let utils = Utils()
    func play(playerNumber:Int,players:[Player],dominos:[Domino],gs:GameState,dominoModels:[Entity]){
        var dominoToPlay = players[playerNumber].firstStillHolding(dominos: dominos)
        var dominoSelected = false
        var leadingTrump = false
        var pointsPlaying = 0
        for dominoIndex in players[playerNumber].holdingDominos {
            if !dominos[dominoIndex].isPlayed {
                if gs.dominosLayed.count == 0 { // if leading
                    if dominos[dominoIndex].isDouble() { //if double
                        if !leadingTrump && !dominos[dominoToPlay].isDouble(){
                            // prefer leading trump or previous double
                            dominoToPlay = dominoIndex
                            if dominos[dominoIndex].isTrump(gs: gs) { // lead double trump
                                gs.currentSuit = gs.trump
                                leadingTrump = true
                            }else{
                                gs.currentSuit = dominos[dominoIndex].values.max()!
                            }
                            dominoSelected = true
                        }
                    }else{ // if not double
                        if dominos[dominoIndex].isHighestRemainingTrump(gs:gs,dominos:dominos){
                                dominoToPlay = dominoIndex
                                leadingTrump = true
                                dominoSelected = true
                               gs.currentSuit = gs.trump
                            }
                        }
                    }else { // if not leading
                        if dominos[dominoIndex].values[0] == gs.currentSuit || dominos[dominoIndex].values[1] == gs.currentSuit { //if can follow suit
                            //todo: add play best or worst logic
                            dominoToPlay = dominoIndex
                            dominoSelected = true
                        }else{ // can't follow suit
                            if utils.partnerWinning(playerIndex: playerNumber, gs: gs, dominos: dominos, utils: utils, players: players) {
                                if dominos[dominoIndex].isPointsDomino(){
                                    if dominos[dominoIndex].points() > pointsPlaying {
                                        pointsPlaying = dominos[dominoIndex].points()
                                        dominoSelected = true
                                        dominoToPlay = dominoIndex
                                    }
                                }
                            }
                        }
                }
            }
        }
        if dominoSelected == false { // play trash
            leadingTrump = false // in case we got here after setting that
            for dominoIndex in players[playerNumber].holdingDominos {
                if !dominos[dominoIndex].isPlayed {
                    if !leadingTrump {
                        dominoToPlay = dominoIndex
                        if dominos[dominoIndex].isTrump(gs:gs){ // if we have a trump stop checking
                            leadingTrump = true
                        }
                        if gs.dominosLayed.count == 0 { // set the suit if we got here while leading
                            if dominos[dominoIndex].isTrump(gs:gs) {
                                gs.currentSuit = gs.trump
                            }else{
                                gs.currentSuit = dominos[dominoIndex].values.max()!
                            }
                        }
                    }
                }
            }
        }
        if gs.dominosLayed.count == 0 {
            if dominos[dominoToPlay].isTrump(gs:gs) {
                gs.currentSuit = gs.trump
            }else{
                gs.currentSuit = dominos[dominoToPlay].values.max()!
            }
        }
        print("suit",gs.currentSuit,"player",playerNumber,"play",dominos[dominoToPlay].values)
        dominos[dominoToPlay].playDomino(models: dominoModels)
        dominos[dominoToPlay].isPlayed = true
        gs.dominosLayed.append(dominoToPlay)
    }
}
