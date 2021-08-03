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
                    z += 0.4
                }
                if (index! > 20){
                    //good
                    z -= 0.6
                }
                if (index! > 6 && index! < 14){
                    x -= 0.7
                    //z -= 0.2
                }
                if (index! > 13 && index! < 21){
                    x += 0.45
                }
                dominoModel.position.x += x
                dominoModel.position.z += z
            }
        }
    }
}
