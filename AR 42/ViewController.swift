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
    @IBOutlet var usLabel: UILabel!
    @IBOutlet var themLabel: UILabel!
    @IBOutlet var themMarksLabel: UILabel!
    @IBOutlet var trumpLabel: UILabel!
    @IBOutlet var trumpValLabel: UILabel!
    @IBOutlet var usMarksLabel: UILabel!
    @IBOutlet var currentBidLabel: UILabel!
    @IBOutlet var currentBidValLabel: UILabel!
    @IBOutlet var bidConfirm: UIButton!
    @IBOutlet var usCollectionLabel: UILabel!
    @IBOutlet var themCollectionLabel: UILabel!
    var utils = Utils()
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
        var dominoDems = utils.genDems()
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
            let dominoGroup = try! Entity.load(named: "color.usda")
            let dominoModel = dominoGroup.findEntity(named: name)
            dominoModel!.generateCollisionShapes(recursive: true)
            dominoModels.append(dominoModel!)
        }
        
        for (index, dominoModel) in dominoModels.enumerated() {
            
            let initPos = utils.initPos(index: index)
            dominoModel.position = [initPos[0],-1,initPos[1]]
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
        decideBid(playerIndex: whosFirst)
        bidSelector.delegate = self
        bidSelector.dataSource = self
        
    } // end view load
    // put these somewhere better, like in an object
    var playerBid = 0
    var bid = 0
    var bidwinner = 0
    var trump = 7
    var startingPlayer = 0
    var bids: [[Int]] = []
    var dominosLayed: [Int] = []
    var currentSuit = 0
    var usScore = 0
    var ThemScore = 0
    var whosFirst = 0
    var usMarks = 0
    var themMarks = 0

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
            bidChoices = ["no trump","blank","1","2","3","4","5","6"]
            bidConfirm.setTitle("Select Trump", for: .normal)
            bidSelector.reloadAllComponents()

            if playerBid > bid && playerBid > 1 {
                bid = playerBid
            }else{
                bidSelector.isHidden = true
                bidConfirm.isHidden = true
                bids.append([0,playerBid,playerTrump])
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
                currentBidLabel.isHidden = true
                //currentBidValLabel.isHidden = true
            }
        }else{
            if playerBid >= bid && playerBid > 1 {
                let bidText = bidChoices[bidSelector.selectedRow(inComponent: 0)]
                bid = playerBid
                if bidText == "blank" {
                    playerTrump = 0
                }else if bidText == "no trump"{
                    playerTrump = 7
                }else {
                    playerTrump = Int(bidText) ?? 1
                }
            }
            bids.append([0,playerBid,playerTrump])
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
            currentBidLabel.isHidden = true
            //currentBidValLabel.isHidden = true
        }
        
    }
    // todo: add trump as leading suit
    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: arView)
        if let playedDominoModel = arView.entity(at: tapLocation){
            let impact = UIImpactFeedbackGenerator()
            impact.impactOccurred()
            for domino in dominos{
                if domino.name == playedDominoModel.name {
                    if dominosLayed.count > 0 {
                        if domino.values.contains(currentSuit){
                            playDomino(domino:domino)
                            domino.isPlayed = true
                            dominosLayed.append(dominos.firstIndex{$0 === domino}!)
                            playTurn(playerNumber: 1) // have the left player go after user
                        }else {
                            var hadSuitDomino = false
                            var suitAlerted = false
                            for domIndex in players[0].holdingDominos{
                                if !dominos[domIndex].isPlayed && dominos[domIndex].values.contains(currentSuit)
                                    && !suitAlerted && bid >= 30 {
                                    print("suit alert")
                                    //todo: suit alert not working
                                    let alert = UIAlertController(title: "Follow Suit", message: "You can follow suit", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "Good Catch", style: .default, handler: nil))
                                    self.present(alert, animated: true)
                                    hadSuitDomino = true
                                    suitAlerted = true
                                }
                            }
                            if !hadSuitDomino {
                                playDomino(domino:domino)
                                domino.isPlayed = true
                                dominosLayed.append(dominos.firstIndex{$0 === domino}!)
                                playTurn(playerNumber: 1) // have the left player go after user
                            }
                        }
                    }else {
                        if dominos[dominos.firstIndex{$0 === domino}!].values[0] == trump ||
                            dominos[dominos.firstIndex{$0 === domino}!].values[1] == trump {
                            currentSuit = trump
                        }else{
                            currentSuit = dominos[dominos.firstIndex{$0 === domino}!].values.max()!
                        }
                        playDomino(domino:domino)
                        domino.isPlayed = true
                        dominosLayed.append(dominos.firstIndex{$0 === domino}!)
                        playTurn(playerNumber: 1) // have the left player go after user
                    }
                }
            }
        }
    }
    func playDomino (domino:Domino){
        for dominoModel in dominoModels{
            if dominoModel.name == domino.name{
                var flipDownTransform = dominoModel.transform
                flipDownTransform.rotation = simd_quatf(angle: 1.72, axis: [0,0,1])
                flipDownTransform.rotation *= simd_quatf(angle: -1.72, axis: [0,1,0])
                dominoModel.move(to: flipDownTransform, relativeTo: dominoModel.parent)
                let index = dominoModels.firstIndex{$0 === dominoModel}
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
    func decideBid (playerIndex:Int){
        print("playerIndex",playerIndex)
        if players[playerIndex].isUser {
            bidSelector.isHidden = false
            bidConfirm.isHidden = false
            currentBidLabel.isHidden = false
            currentBidValLabel.isHidden = false
            if bids.count > 0 {
                var bidText = ""
                var bidValText = ""
                for bidItem in bids {
                    if bidItem[1] == 1 {
                        bidValText = "pass"
                    } else{
                        bidValText = String(bidItem[1])
                    }
                    bidText += players[bidItem[0]].name + ":" + bidValText + ". "
                }
                currentBidValLabel.text = bidText
            }
        } else{
            let bidDecision = BidDecision(player: players[playerIndex], dominos: dominos, currentBid: bid)
            if bidDecision.bidChoice > bid {
                bid = bidDecision.bidChoice
            }
            bids.append([playerIndex,bidDecision.bidChoice,bidDecision.trumpChoice])
            print(bids)
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
        for bidItem in bids {
            if bidItem[1] == bid {
                trump = bidItem[2]
                startingPlayer = bidItem[0]
                currentBidValLabel.text = players[bidItem[0]].name + " bid " + String(bid)
                currentBidValLabel.isHidden = false
                currentBidLabel.isHidden = true
                trumpLabel.isHidden = false
                var trumpText = ""
                if trump == 7 {
                    trumpText = "No Trump"
                } else if trump == 0 {
                    trumpText = "Blanks"
                } else {
                    trumpText = String(trump)
                }
                trumpValLabel.text = trumpText
                trumpValLabel.isHidden = false
            }
        }
        if bid < 30 {
            print("hammer")
            bid = 30
            startingPlayer = bids[3][0] // hammer
            currentBidValLabel.text = players[bids[3][0]].name + " bid " + String(bid) + " (hammer)"
            currentBidValLabel.isHidden = false
        }
        print("startingplayer",startingPlayer)
        bidwinner = startingPlayer
        playTurn(playerNumber:startingPlayer)
    }
    func startNewRound(){
        //todo: add what happens when someone gets 7 marks
        playerBid = 0
        bid = 0
        bidwinner = 0
        trump = 7
        startingPlayer = 0
        bids = []
        dominosLayed = []
        currentSuit = 0
        usScore = 0
        ThemScore = 0
        dominos = []
        dominoModels = []
        usCollectionLabel.text = ""
        themCollectionLabel.text = ""
        usLabel.text = "0"
        themLabel.text = "0"
        trumpLabel.isHidden = true
        trumpValLabel.isHidden = true
        trumpValLabel.text = "No Trumo"
        players = []
        if whosFirst == 3 {
            whosFirst = 0
        } else {
            whosFirst += 1
        }
        viewDidLoad()
    }
    func playTurn(playerNumber:Int) {
        if dominosLayed.count == 4 {
            var score = 1
            var trumpPlayed = false
            var highestTrump = 0
            var higestTrumpUser = 4 //above the index of users
            var winnerIndex = 0
            let leadSuit = dominos[dominosLayed[0]].values.max()
            var highestFollow = 0
            var highestFollowerIndex = 0
            var playedDominoText = ""
            for index in dominosLayed {
                playedDominoText += dominos[index].name.dropFirst(1) + " "
                // check for points dominos
                if dominos[index].values[0] + dominos[index].values[1] == 5 || dominos[index].values[0] + dominos[index].values[1] == 10 {
                    score += dominos[index].values[0] + dominos[index].values[1]
                }
                
                //check for trump dominos played
                if dominos[index].values.contains(trump){
                    trumpPlayed = true
                    var offIndex = 0
                    // checks for double trump
                    if dominos[index].values[0] == trump && dominos[index].values[1] == trump {
                        highestTrump = 7
                        higestTrumpUser = utils.whoPlayedDomino(players: players,index: index)
                    } else {
                        if dominos[index].values[0] == trump{
                            offIndex = 1
                        }
                        if dominos[index].values[offIndex] >= highestTrump {
                            highestTrump = dominos[index].values[offIndex]
                            higestTrumpUser = utils.whoPlayedDomino(players: players,index: index)
                        }
                    }
                } else {
                    if dominos[index].values.contains(leadSuit!){
                        var offIndex = 0
                        if dominos[index].values[0] == leadSuit && dominos[index].values[1] == leadSuit {
                            highestFollow = 7
                            //todo: change to a playerIsHoldingDomino function
                            highestFollowerIndex = utils.whoPlayedDomino(players: players,index: index)
                        } else {
                            if dominos[index].values[0] == leadSuit{
                                offIndex = 1
                            }
                            if dominos[index].values[offIndex] >= highestFollow {
                                highestFollow = dominos[index].values[offIndex]
                                //todo: change to a playerIsHoldingDomino function
                                highestFollowerIndex = utils.whoPlayedDomino(players: players,index: index)
                            }
                        }
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
                    // removes the models for the played dominos
                    for model in dominoModels {
                        if model.name == dominos[index].name {
                            model.removeFromParent()
                        }
                    }
                }
            }
            if trumpPlayed {
                winnerIndex = higestTrumpUser
            } else {
                winnerIndex = highestFollowerIndex
            }
            // sets adds to the score of the winers
            if winnerIndex == 0 || winnerIndex == 2 {
                usScore += score
                usLabel.text = String(usScore)
                usCollectionLabel.text?.append(String(playedDominoText) + "\n")
            }else {
                ThemScore += score
                themLabel.text = String(ThemScore)
                themCollectionLabel.text?.append(String(playedDominoText) + "\n")
            }
            // checks for round ending conditions
            var setScore = 0
            if bidwinner == 0 || bidwinner == 2 {
                setScore = ThemScore
            }else {
                setScore = usScore
            }
            if usScore + ThemScore == 42 || 42 - setScore < bid || usScore >= bid || ThemScore >= bid {
                var roundWinText = ""
                var ackText = "Awesome"
                if bidwinner == 0 || bidwinner == 2 {
                    if usScore >= bid {
                        usMarks += 1
                        usMarksLabel.text = String(usMarks)
                        roundWinText = "We"
                    }else {
                        themMarks += 1
                        themMarksLabel.text = String(themMarks)
                        roundWinText = "They"
                        ackText = "Bummer"
                    }
                }else {
                    if ThemScore >= bid {
                        themMarks += 1
                        themMarksLabel.text = String(themMarks)
                        roundWinText = "They"
                        ackText = "Bummer"
                    }else {
                        usMarks += 1
                        usMarksLabel.text = String(usMarks)
                        roundWinText = "We"
                    }
                }
                let alert = UIAlertController(title: "Round Won", message: roundWinText + " won the round", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: ackText, style: .default, handler: nil))
                self.present(alert, animated: true)
                for domino in dominos {
                    if !domino.isPlayed {
                        playDomino(domino: domino)
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [self] in
                    for domino in dominos {
                        if !domino.isPlayed {
                            domino.isPlayed = true
                            for model in dominoModels {
                                if model.name == domino.name {
                                    model.removeFromParent()
                                }
                            }
                        }
                    }
                    startNewRound()
                }
                
            }else { // next hand in same round
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
                    dominosLayed = []
                    playTurn(playerNumber: winnerIndex)
                }
            }
        } else { // if not time to score
            if playerNumber != 0 {
                var dominoToPlay = 0
                var dominoSelected = false
                for dominoIndex in players[playerNumber].holdingDominos {
                    // todo: inform leading suit
                    if !dominos[dominoIndex].isPlayed {
                        if dominosLayed.count == 0 { // todo: what if doesn't have double
                            if dominos[dominoIndex].values[0] == dominos[dominoIndex].values[1] { // if have double play it, todo: improve
                                dominoToPlay = dominoIndex
                                if dominos[dominoIndex].values[0] == trump ||
                                    dominos[dominoIndex].values[1] == trump {
                                    currentSuit = trump
                                }else{
                                    currentSuit = dominos[dominoIndex].values.max()!
                                }
                                dominoSelected = true
                            } // currently plays the last double found, todo: improve
                        
                        } else {
                            if dominos[dominoIndex].values[0] == currentSuit || dominos[dominoIndex].values[1] == currentSuit {
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
                            if dominosLayed.count == 0 {
                                if dominos[dominoIndex].values[0] == trump ||
                                    dominos[dominoIndex].values[1] == trump {
                                    currentSuit = trump
                                }else{
                                    currentSuit = dominos[dominoIndex].values.max()!
                                }
                            }
                        }
                    }
                }
                playDomino(domino: dominos[dominoToPlay])
                dominos[dominoToPlay].isPlayed = true
                // send to the next player's turn
                dominosLayed.append(dominoToPlay)
                if playerNumber == 3 {
                    playTurn(playerNumber: 0)
                }else{
                    playTurn(playerNumber: playerNumber + 1)
                }
            } else { // is users turn
                print("current suit",currentSuit)
            }
        }
    }
}
