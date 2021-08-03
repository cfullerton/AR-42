//
//  player.swift
//  AR 42
//
//  Created by Conner Fullerton on 8/2/21.
//

import Foundation

class Player {
    var isUser: Bool = false
    var holdingDominos: [Int]  = []
    var didBid = false
    var bidValue = 0
    var name = ""
    
    init(i:Int) {
        if i == 0 {
            isUser = true
            for j in 21...27 {
                holdingDominos.append(j)
            }
            name = "user"
        } else if i == 1 {
            
            isUser = false
            for j in 14...20 {
                holdingDominos.append(j)
            }
            name = "left"
            
        } else if i == 2 {
           
            isUser = false
            for j in 0...6 {
                holdingDominos.append(j)
            }
            name = "across"
        } else if i == 3 {
           
            isUser = false
            for j in 7...13 {
                holdingDominos.append(j)
            }
            name = "right"
        }
    }
}
