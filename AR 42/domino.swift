//
//  domino.swift
//  AR 42
//
//  Created by Conner Fullerton on 8/2/21.
//

import Foundation
import RealityKit
import SceneKit.ModelIO

class Domino {
    var values: [Int] = []
    var name: String = ""
    var isPlayed = false
    
    init(nameString:String,dem:[Int]) {
        name = nameString
        values = dem
    }
    func isDouble() -> Bool{
        return values[0] == values[1]
    }
    func isTrump(gs:GameState) -> Bool{
        return values[0] == gs.trump || values[1] == gs.trump
    }
    func isPointsDomino() -> Bool{
        return values[0] + values[1] == 5 || values[0] + values[1] == 10
    }
    func points() -> Int {
        var pointValue = 0
        if isPointsDomino(){
            pointValue = values[0] + values[1]
        }
        return pointValue
    }
    func isHighestRemainingTrump(gs:GameState,dominos:[Domino]) -> Bool {
        var higherTrumpStillOut = false
        if isTrump(gs: gs){
            var myOff = 0
            if values[0] == gs.trump{
                myOff = values[1]
            }else{
                myOff = values[0]
            }
            var trumpsPlayed:[Int] = []
            for playedDomino in dominos{ // finds what trumps have been played
                if playedDomino.isPlayed{
                    if playedDomino.isTrump(gs:gs){
                        if playedDomino.values[0] == gs.trump{
                            trumpsPlayed.append(playedDomino.values[1])
                        }else{
                            trumpsPlayed.append(playedDomino.values[0])
                        }
                    }
                }
            }
            var countdown = 6
            while countdown > myOff && !higherTrumpStillOut {
                if !trumpsPlayed.contains(countdown){
                    higherTrumpStillOut = true
                }
                countdown -= 1
            }
        }
        return !higherTrumpStillOut
    }
    func playDomino (models:[Entity]){
        for dominoModel in models{
            if dominoModel.name == name{
                var flipDownTransform = dominoModel.transform
                flipDownTransform.rotation = simd_quatf(angle: 1.72, axis: [0,0,1])
                flipDownTransform.rotation *= simd_quatf(angle: -1.72, axis: [0,1,0])
                dominoModel.move(to: flipDownTransform, relativeTo: dominoModel.parent)
                let index = models.firstIndex{$0 === dominoModel}
                var x:Float = 0.0
                var z:Float = 0.0
                if (index! < 7) {
                    //tested
                    z += 0.5
                    if [0,3,6].contains(index){
                        x += 0.2
                    }else if [2,5].contains(index){
                        x -= 0.2
                    }
                }
                if (index! > 20){
                    //good
                    z -= 0.6
                }
                if (index! > 6 && index! < 14){
                    if [9,12].contains(index){
                        x+=0.2
                    }else if [8,11].contains(index){
                        x-=0.5
                    }
                    x -= 0.5
                    //z -= 0.2
                }
                if (index! > 13 && index! < 21){
                    if [14,17,20].contains(index){
                        x -= 0.4
                    }else{
                        x += 0.19
                    }
                    if [16,19].contains(index){
                        x-=0.12
                    }
                    x += 0.4
                }
                dominoModel.position.x += x
                dominoModel.position.z += z
            }
        }
    }
}
