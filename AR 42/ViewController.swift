//
//  ViewController.swift
//  AR 42
//
//  Created by Conner Fullerton on 7/14/21.
//

import UIKit
import RealityKit
import SceneKit.ModelIO

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
    @IBOutlet var arView: ARView!
    @IBOutlet var bidSelector: UIPickerView!

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return bidChoices.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return bidChoices[row]
    }
    
    var utils = Utils()
    var dominos : [Domino] = []
    var dominoModels: [Entity] = []
    var players: [Player] = []
    var bidChoices = ["none","30","31","32","33","34","35","36","37","38","39","40","41","one mark"]
    
    override func viewDidLoad() {
        var dominoDems = utils.genDems()
        dominoDems.shuffle()
        
        super.viewDidLoad()
        let anchor = AnchorEntity(plane: .horizontal)
        arView.scene.addAnchor(anchor)
        
        let dominoGroup = try! Entity.load(named: "color.usda")
        for i in 0...27 {
            let name = "_" + String(dominoDems[i][0]) + "_" + String(dominoDems[i][1])
            let newDomino = Domino(nameString: name, dem: dominoDems[i])
            dominos.append(newDomino)
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
            let player = Player(i:i)
            players.append(player)
        }
        decideBid(playerIndex: gs.whosFirst)
        bidSelector.delegate = self
        bidSelector.dataSource = self
//        for i in 14...20{
//            print(i,dominos[i].values)
//            if [14,17,20].contains(i){
//               
//            }else{
//                dominos[i].playDomino(models: dominoModels)
//            }
//        }
        
    } // end view load
    var gs = GameState()
    @IBAction func onClick(_ sender: UIButton, forEvent event: UIEvent){
        var playerTrump = 7
        if gs.playerBid == 0 {
            let bidText = bidChoices[bidSelector.selectedRow(inComponent: 0)]
            if bidText == "none"{
                gs.playerBid = 1
            }else if bidText == "one mark"{
                gs.playerBid = 42
            }else{
                gs.playerBid = Int(bidText) ?? 1
            }
            bidChoices = ["no trump","blank","1","2","3","4","5","6"]
            bidConfirm.setTitle("Select Trump", for: .normal)
            bidSelector.reloadAllComponents()

            if gs.playerBid > gs.bid && gs.playerBid > 1 {
                gs.bid = gs.playerBid
            }else{
                bidSelector.isHidden = true
                bidConfirm.isHidden = true
                gs.bids.append([0,gs.playerBid,playerTrump])
               bidChoices = ["none","30","31","32","33","34","35","36","37","38","39","40","41","one mark"]
                if gs.bids.count < 4 {
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
            if gs.playerBid >= gs.bid && gs.playerBid > 1 {
                let bidText = bidChoices[bidSelector.selectedRow(inComponent: 0)]
                gs.bid = gs.playerBid
                if bidText == "blank" {
                    playerTrump = 0
                }else if bidText == "no trump"{
                    playerTrump = 7
                }else {
                    playerTrump = Int(bidText) ?? 1
                }
            }
            gs.bids.append([0,gs.playerBid,playerTrump])
           bidChoices = ["none","30","31","32","33","34","35","36","37","38","39","40","41","one mark"]
            if gs.bids.count < 4 {
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
                    if gs.dominosLayed.count > 0 {
                        if domino.values.contains(gs.currentSuit){
                            domino.playDomino(models: dominoModels)
                            domino.isPlayed = true
                            gs.dominosLayed.append(dominos.firstIndex{$0 === domino}!)
                            playTurn(playerNumber: 1) // have the left player go after user
                        }else {
                            var hadSuitDomino = false
                            var suitAlerted = false
                            for domIndex in players[0].holdingDominos{
                                if !dominos[domIndex].isPlayed && dominos[domIndex].values.contains(gs.currentSuit)
                                    && !suitAlerted && gs.bid >= 30 {
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
                                domino.playDomino(models: dominoModels)
                                domino.isPlayed = true
                                gs.dominosLayed.append(dominos.firstIndex{$0 === domino}!)
                                playTurn(playerNumber: 1) // have the left player go after user
                            }
                        }
                    }else {
                        if dominos[dominos.firstIndex{$0 === domino}!].values[0] == gs.trump ||
                            dominos[dominos.firstIndex{$0 === domino}!].values[1] == gs.trump {
                            gs.currentSuit = gs.trump
                        }else{
                            gs.currentSuit = dominos[dominos.firstIndex{$0 === domino}!].values.max()!
                        }
                        domino.playDomino(models: dominoModels)
                        domino.isPlayed = true
                        gs.dominosLayed.append(dominos.firstIndex{$0 === domino}!)
                        playTurn(playerNumber: 1) // have the left player go after user
                    }
                }
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
            if gs.bids.count > 0 {
                var bidText = ""
                var bidValText = ""
                for bidItem in gs.bids {
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
            let bidDecision = BidDecision(player: players[playerIndex], dominos: dominos, currentBid: gs.bid)
            if bidDecision.bidChoice > gs.bid {
                gs.bid = bidDecision.bidChoice
            }
            gs.bids.append([playerIndex,bidDecision.bidChoice,bidDecision.trumpChoice])
            if gs.bids.count < 4 {
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
        for bidItem in gs.bids {
            if bidItem[1] == gs.bid {
                gs.trump = bidItem[2]
                gs.startingPlayer = bidItem[0]
                currentBidValLabel.text = players[bidItem[0]].name + " bid " + String(gs.bid)
                currentBidValLabel.isHidden = false
                currentBidLabel.isHidden = true
                trumpLabel.isHidden = false
                var trumpText = ""
                if gs.trump == 7 {
                    trumpText = "No Trump"
                } else if gs.trump == 0 {
                    trumpText = "Blanks"
                } else {
                    trumpText = String(gs.trump)
                }
                trumpValLabel.text = trumpText
                trumpValLabel.isHidden = false
            }
        }
        if gs.bid < 30 {
            print("hammer")
            gs.bid = 30
            gs.startingPlayer = gs.bids[3][0] // hammer
            currentBidValLabel.text = players[gs.bids[3][0]].name + " bid " + String(gs.bid) + " (hammer)"
            currentBidValLabel.isHidden = false
        }
        print("startingplayer",gs.startingPlayer)
        gs.bidwinner = gs.startingPlayer
        playTurn(playerNumber:gs.startingPlayer)
    }
    func startNewRound(){
        //todo: add what happens when someone gets 7 marks
        gs.reset()
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
        viewDidLoad()
    }
    func playTurn(playerNumber:Int) {
        if gs.dominosLayed.count == 4 {
            let finish = Finish()
            finish.round(gs:gs,dominos:dominos,utils:utils,players:players)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
                // removes the models for the played dominos
                for index in gs.dominosLayed {
                    for model in dominoModels {
                        if model.name == dominos[index].name {
                            model.removeFromParent()
                        }
                    }
                }
            }
            // sets adds to the score of the winers
            if finish.roundWinner == 0 || finish.roundWinner == 2 {
                gs.usScore += finish.roundScore
                usLabel.text = String(gs.usScore)
                usCollectionLabel.text?.append(finish.domsPlayed + "\n")
            }else {
                gs.ThemScore += finish.roundScore
                themLabel.text = String(gs.ThemScore)
                themCollectionLabel.text?.append(finish.domsPlayed + "\n")
            }
            // checks for round ending conditions
            if finish.checkPoints(gs: gs) {
                var roundWinText = ""
                var ackText = "Awesome"
                if gs.bidwinner == 0 || gs.bidwinner == 2 {
                    if gs.usScore >= gs.bid {
                        gs.usMarks += 1
                        usMarksLabel.text = String(gs.usMarks)
                        roundWinText = "We"
                    }else {
                        gs.themMarks += 1
                        themMarksLabel.text = String(gs.themMarks)
                        roundWinText = "They"
                        ackText = "Bummer"
                    }
                }else {
                    if gs.ThemScore >= gs.bid {
                        gs.themMarks += 1
                        themMarksLabel.text = String(gs.themMarks)
                        roundWinText = "They"
                        ackText = "Bummer"
                    }else {
                        gs.usMarks += 1
                        usMarksLabel.text = String(gs.usMarks)
                        roundWinText = "We"
                    }
                }
                let alert = UIAlertController(title: "Round Won", message: roundWinText + " won the round", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: ackText, style: .default, handler: nil))
                self.present(alert, animated: true)
                for domino in dominos {
                    if !domino.isPlayed {
                        domino.playDomino(models: dominoModels)
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
                    gs.dominosLayed = []
                    playTurn(playerNumber: finish.roundWinner)
                }
            }
        } else { // if not time to score
            if playerNumber != 0 {
               let computerPlay = ComputerPlay()
                computerPlay.play(playerNumber:playerNumber,players:players,dominos:dominos,gs:gs,dominoModels:dominoModels)
                
                if playerNumber == 3 {
                    playTurn(playerNumber: 0)
                }else{
                    playTurn(playerNumber: playerNumber + 1)
                }
            } else { // is users turn
                print("current suit",gs.currentSuit)
            }
        }
    }
}
