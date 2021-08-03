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
    func play(playerNumber:Int,players:[Player],dominos:[Domino],gs:GameState,dominoModels:[Entity]){
        var dominoToPlay = 0
        var dominoSelected = false
        for dominoIndex in players[playerNumber].holdingDominos {
            // todo: inform leading suit
            if !dominos[dominoIndex].isPlayed {
                if gs.dominosLayed.count == 0 { // todo: what if doesn't have double
                    if dominos[dominoIndex].values[0] == dominos[dominoIndex].values[1] { // if have double play it, todo: improve
                        dominoToPlay = dominoIndex
                        if dominos[dominoIndex].values[0] == gs.trump ||
                            dominos[dominoIndex].values[1] == gs.trump {
                            gs.currentSuit = gs.trump
                        }else{
                            gs.currentSuit = dominos[dominoIndex].values.max()!
                        }
                        dominoSelected = true
                    } // currently plays the last double found, todo: improve
                
                } else {
                    if dominos[dominoIndex].values[0] == gs.currentSuit || dominos[dominoIndex].values[1] == gs.currentSuit {
                        dominoToPlay = dominoIndex
                        dominoSelected = true
                    } // currently plays the last legal domino, fix
                }
            }
        }
        if dominoSelected == false { // todo: change to trash or points
            for dominoIndex in players[playerNumber].holdingDominos {
                if !dominos[dominoIndex].isPlayed {
                    dominoToPlay = dominoIndex
                    if gs.dominosLayed.count == 0 {
                        if dominos[dominoIndex].values[0] == gs.trump ||
                            dominos[dominoIndex].values[1] == gs.trump {
                            gs.currentSuit = gs.trump
                        }else{
                            gs.currentSuit = dominos[dominoIndex].values.max()!
                        }
                    }
                }
            }
        }
        dominos[dominoToPlay].playDomino(models: dominoModels)
        dominos[dominoToPlay].isPlayed = true
        gs.dominosLayed.append(dominoToPlay)
    }
}
