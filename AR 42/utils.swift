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
            x += 0.9
            z += 0.2
        }
        if (index > 13 && index < 21){
            x -= 0.7
            x -= x * 0.2
        }
        return [x,z]
    }
    
    func whoPlayedDomino(players:[Player],index:Int) -> Int {
        //todo: check that setting this isn't harmful
        var playerIndex = 4
        for player in players {
            if player.holdingDominos.contains(index){
                playerIndex = players.firstIndex{$0 === player}!
            }
        }
        return playerIndex
    }
    
}
