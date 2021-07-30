//
//  ViewController.swift
//  AR 42
//
//  Created by Conner Fullerton on 7/14/21.
//

import UIKit
import RealityKit
import SceneKit.ModelIO

class Domino {
    var values: [Int] = []
    var name: String = ""
    var isPlayed = false
}

class Player {
    var isUser: Bool = false
    var holdingDominos: [Int]  = []
    var didBid = false
    var bidValue = 0
    var name = ""
}


class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet var bidConfirm: UIButton!
    var bidChoices = ["none","30","31","32","33","34","35","36","37","38","39","40","41","one mark"]
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return bidChoices.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return bidChoices[row]
    }
    var dominos : [Domino] = []
    @IBOutlet var arView: ARView!
    @IBOutlet var bidSelector: UIPickerView!
    var dominoModels: [Entity] = []
    var players: [Player] = []
    override func viewDidLoad() {
        var dominoDems: [[Int]] = []
        
        //generate an array of all dominos
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
        dominoDems.shuffle()
        super.viewDidLoad()
        let anchor = AnchorEntity(plane: .horizontal)
        arView.scene.addAnchor(anchor)
        
        for i in 0...27 {
            let name = "_" + String(dominoDems[i][0]) + "_" + String(dominoDems[i][1])
            let newDomino = Domino()
            newDomino.name = name
            newDomino.values = dominoDems[i]
            dominos.append(newDomino)
            let dominoGroup = try! Entity.load(named: "dom.usda")
            let dominoModel = dominoGroup.findEntity(named: name)
            dominoModel!.generateCollisionShapes(recursive: true)
            dominoModels.append(dominoModel!)
        }
        
        dominoModels.shuffle()
        for (index, dominoModel) in dominoModels.enumerated() {
            
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
                x -= 0.6
            }
            dominoModel.position = [x,-1,z]
            anchor.addChild(dominoModel)
            //rotate the dominos vertical
            var sideTransform = dominoModel.transform
            sideTransform.rotation = simd_quatf(angle: 1.72, axis: [0,0,1])
            dominoModel.move(to: sideTransform, relativeTo: dominoModel.parent)
            //rotate the players to the side
            if (index > 6 && index < 14){
                // right player rotation
                var sideTransform = dominoModel.transform
                sideTransform.rotation *= simd_quatf(angle: -1.72, axis: [1,0,0])
                dominoModel.move(to: sideTransform, relativeTo: dominoModel.parent)
            }else if (index > 13 && index < 21){
                // left player rotation
                var sideTransform = dominoModel.transform
                sideTransform.rotation *= simd_quatf(angle: 1.72, axis: [1,0,0])
                dominoModel.move(to: sideTransform, relativeTo: dominoModel.parent)
            }else if (index > 20){
                // player dominos rotation
                var sideTransform = dominoModel.transform
                sideTransform.rotation *= simd_quatf(angle: 3.14, axis: [1,0,0])
                dominoModel.move(to: sideTransform, relativeTo: dominoModel.parent)
            }
        }
        for i in 0...3{
            if i == 0 {
                var player = Player()
                player.isUser = true
                for j in 21...27 {
                    player.holdingDominos.append(j)
                }
                player.name = "user"
                players.append(player)
            } else if i == 1 {
                var player = Player()
                player.isUser = false
                for j in 14...20 {
                    player.holdingDominos.append(j)
                }
                player.name = "left"
                players.append(player)
            } else if i == 2 {
                var player = Player()
                player.isUser = false
                for j in 0...6 {
                    player.holdingDominos.append(j)
                }
                player.name = "across"
                players.append(player)
            } else if i == 3 {
                var player = Player()
                player.isUser = false
                for j in 7...13 {
                    player.holdingDominos.append(j)
                }
                player.name = "right"
                players.append(player)
            }
            
        }
        
        
        
        decideBid(playerIndex:0)
        bidSelector.delegate = self
        bidSelector.dataSource = self
    } // end view load
    // put these somewhere better, like in an object
    var playerBid = 0
    var bid = 0
    var bidwinner = 0
    var bids: [[Int]] = []
    @IBAction func onClick(_ sender: UIButton, forEvent event: UIEvent){
        var playerTrump = 7
        if playerBid == 0 {
            let bidText = bidChoices[bidSelector.selectedRow(inComponent: 0)]
            if bidText == "none"{
                playerBid = 1
            }else if bidText == "one mark"{
                playerBid = 42
            }else{
                playerBid = Int(bidText) ?? 1
            }
            bidChoices = ["1","2","3","4","5","6"]
            bidConfirm.setTitle("Select Trump", for: .normal)
            bidSelector.reloadAllComponents()
            // todo: test case where user doesn't bid first
            if playerBid > bid {
                bid = playerBid
            }else{
                bidSelector.isHidden = true
                bidConfirm.isHidden = true
            }
        }else{
            if playerBid > bid {
                let bidText = bidChoices[bidSelector.selectedRow(inComponent: 0)]
                bid = playerBid
                playerTrump = Int(bidText) ?? 1
                print(playerTrump)
            }
            bids.append([0,playerBid,playerTrump])
            print(playerTrump)
            print(bids)
           bidChoices = ["none","30","31","32","33","34","35","36","37","38","39","40","41","one mark"]
            if bids.count < 4 {
                let newIndex = 1
                decideBid(playerIndex: newIndex)
            }else {
                startGame()
            }
            bidConfirm.setTitle("Place Bid", for: .normal)
            bidSelector.reloadAllComponents()
            bidSelector.isHidden = true
            bidConfirm.isHidden = true
        }
        
    }
    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: arView)
        print(tapLocation)
        if let playedDominoModel = arView.entity(at: tapLocation){
            for domino in dominos{
                if domino.name == playedDominoModel.name {
                    playDomino(domino:domino)
                }
            }
            
            
        }
    }
    func playDomino (domino:Domino){
        for dominoModel in dominoModels{
            if dominoModel.name == domino.name{
                var flipDownTransform = dominoModel.transform
                flipDownTransform.rotation = simd_quatf(angle: 1.72, axis: [0,0,1])
                flipDownTransform.rotation *= simd_quatf(angle: 90, axis: [1,0,0])
                dominoModel.move(to: flipDownTransform, relativeTo: dominoModel.parent)
                dominoModel.position.x += 0.15
                dominoModel.position.y += 0.15
            }
        }
    }
    func decideBid (playerIndex:Int){
        print(playerIndex)
        if players[playerIndex].isUser {
            bidSelector.isHidden = false
            bidConfirm.isHidden = false
        } else{
            var computerTrump = 7 // no trump
            var computerBid = 0
            var confidence = 0
            var doubles: [Int] = []
            var suitCount: [[Int]] = []
            for i in 0...6 {
                suitCount.append([i,0])
            }
            for dominoIndex in players[playerIndex].holdingDominos{
                let dominoValues = dominos[dominoIndex].name.split(separator: "_").compactMap { Int($0) }
                if dominoValues[0] == dominoValues[1] {
                    doubles.append(dominoValues[0])
                }
                for i in 0...6 {
                    if dominoValues.contains(suitCount[i][0]) {
                        suitCount[i][1] += 1
                    }
                }
            }
            var bestSuit = [0,0]
            var bestSuitCount = 0
            for suit in suitCount {
                if suit[1] > bestSuitCount {
                    bestSuit = suit
                    bestSuitCount = suit[1]
                }
            }
            if doubles.contains(bestSuit[0]) { // if they have the double of their best
                confidence += 20
            }
            if bestSuitCount > 3 { // if they have at least 4 of the same suit
                confidence += 20
            }
            if bestSuit[0] > 3 { // if it is a a high suit
                confidence += 10
            }
            if bestSuit[1] + doubles.count > 5 { // they only have one off domino
                confidence += 30
            }
            if doubles.contains(6){
                confidence += 10
            }
            if doubles.contains(5) {
                confidence += 10
            }
            if doubles.count > 4 { // 4 doubles
                confidence += 30
            }
            if doubles.count > 6 { // all doubles
                confidence += 100
                computerTrump = 7
            } else if doubles.count > 4 && bestSuit[1] < 4 {
                    computerTrump = 7
            } else {
                computerTrump = bestSuit[0]
            }
            if confidence > 100 {
                computerBid = 42
            } else if confidence > 50 {
                computerBid = bid + 1
            }else{
                computerBid = 1
            }
            if computerBid > bid {
                bid = computerBid
            }
            bids.append([playerIndex,computerBid,computerTrump])
            if bids.count < 4 {
                var newIndex = 0
                if playerIndex == 3 {
                    newIndex = 0
                }else {
                    newIndex = playerIndex + 1
                }
                decideBid(playerIndex: newIndex)
            }else{
               startGame()
            }
        }
    }
    func startGame() {
        print(bid,bids)
        
    }
}
