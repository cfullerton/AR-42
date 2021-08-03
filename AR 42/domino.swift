//
//  domino.swift
//  AR 42
//
//  Created by Conner Fullerton on 8/2/21.
//

import Foundation

class Domino {
    var values: [Int] = []
    var name: String = ""
    var isPlayed = false
    
    init(nameString:String,dem:[Int]) {
        name = nameString
        values = dem
    }
}
