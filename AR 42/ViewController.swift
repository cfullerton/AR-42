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
            } else if i == 1 {
                var player = Player()
                player.isUser = false
                for j in 14...20 {
                    player.holdingDominos.append(j)
                }
                player.name = "left"
            } else if i == 2 {
                var player = Player()
                player.isUser = false
                for j in 0...6 {
                    player.holdingDominos.append(j)
                }
                player.name = "across"
            } else if i == 3 {
                var player = Player()
                player.isUser = false
                for j in 7...13 {
                    player.holdingDominos.append(j)
                }
                player.name = "right"
            }
        }
        
        // add bid rotating instead of always starting with player
        for player in players {
            decideBid(player:player)
        }
        bidSelector.delegate = self
        bidSelector.dataSource = self
    } // end view load
    
    var playerBid = 0
    var bid = 0
    var trumpSuit = 1
    @IBAction func onClick(_ sender: UIButton, forEvent event: UIEvent){
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
            if playerBid > bid {
                bid = playerBid
            }else{
                bidSelector.isHidden = true
                bidConfirm.isHidden = true
            }
        }else{
            if playerBid > bid {
                let bidText = bidChoices[bidSelector.selectedRow(inComponent: 0)]
                trumpSuit = Int(bidText) ?? 1
            }
           bidChoices = ["none","30","31","32","33","34","35","36","37","38","39","40","41","one mark"]
            bidConfirm.setTitle("Place Bid", for: .normal)
            bidSelector.reloadAllComponents()
            bidSelector.isHidden = true
            bidConfirm.isHidden = true
        }
    }
    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
        print(sender)
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
    func decideBid (player:Player){
        print(player)
        if player.isUser {
            bidSelector.isHidden = false
            bidConfirm.isHidden = false
        }
        // add logic for computer bidding
        print(player.holdingDominos)
    }
}
