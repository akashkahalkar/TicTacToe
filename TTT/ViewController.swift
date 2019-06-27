//
//  ViewController.swift
//  TTT
//
//  Created by Akash kahalkar on 25/04/19.
//  Copyright © 2019 Akashka. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var particleEmitter: CAEmitterLayer!

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var boardView: Board!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var playerOneScoreLabel: UILabel!
    @IBOutlet weak var computerScoreLabel: UILabel!
    @IBOutlet weak var turnLabel: UILabel!
    
    private var gameStructureArray: [UIButton] = []
    private var currentPlayer = Player.playerOne
    private var playersStates: [String?] = []
    var gameLevel = DifficultyLevel.easy
    private var playerOneScore = 0 {
        didSet {
            playerOneScoreLabel.text = String(playerOneScore)
        }
    }
    
    private var computerScore = 0 {
        didSet {
            computerScoreLabel.text = String(computerScore)
        }
    }
    
    enum DifficultyLevel: Int {
        case easy = 0, medium, hard
    }
    
    enum Player: String {
        case playerOne = "❌"
        case computer = "⭕️"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetPlayerStates()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        createBoard()
        turnLabel.text = "TTT"
    }
    
    @IBAction func segmentedControlClicked(_ sender: UISegmentedControl) {
        gameLevel = DifficultyLevel(rawValue: sender.selectedSegmentIndex) ?? .easy
        playerOneScore = 0
        computerScore = 0
        resetPlayerStates()
    }
    
    @IBAction func okButtonClick(_ sender: Any) {
        showBoardView()
    }
    
    private func resetPlayerStates() {
        currentPlayer = .playerOne
        playersStates = Array(repeating: nil, count: 9)
        gameStructureArray.forEach({$0.setTitle(playersStates[$0.tag], for: .normal)})
//        playerOneScore = 0
//        computerScore = 0
    }
    
    private func updateBoard() {
        gameStructureArray.forEach { (button) in
            button.setTitle(playersStates[button.tag], for: .normal)
        }
    }
    
    private func createBoard() {
        let container = boardView!
        let length = container.bounds.width / 3.0
        let convertedPoint = CGPoint.zero
        var initialX = convertedPoint.x
        var initialY = convertedPoint.y

        var count = 0
        for _ in 1...3 {
            for _ in 1...3 {
                let button = UIButton(frame: CGRect(x: initialX, y: initialY, width: length, height: length))
                //button.layer.borderWidth = 0
                button.tag = count
                button.addTarget(self, action: #selector(cellClick(sender:)), for: .touchUpInside)
                gameStructureArray.append(button)
                initialX += length
                count += 1

            }
            initialY += length
            initialX = convertedPoint.x
        }
        gameStructureArray.forEach({container.addSubview($0)})
    }
    
    @objc func cellClick(sender: UIButton) {
        if currentPlayer == .playerOne, updatePlayerStates(index: sender.tag) {
            updateBoard()
            if !checkGameEnd() {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    
                    if self.updatePlayerStates(index: self.getWinningIndexForComputer()) {
                        self.updateBoard()
                        _ = self.checkGameEnd()
                    }
                }
            }
        }
    }
    
    private func highlightButton(_ indexes: [Int]) {
        let buttons = indexes.map({gameStructureArray[$0]})
        UIView.animate(withDuration: 1.0, animations: {
            buttons.forEach({$0.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)})
        }) { (_) in
            buttons.forEach({$0.transform = CGAffineTransform.identity})
        }
    }
    
    private func checkGameEnd() -> Bool {
        let result = checkIfWinner(in: playersStates, player: currentPlayer)
        if result.0 {
            incrementScore(player: currentPlayer)
            let player = currentPlayer == .playerOne ? "You" : "Computer"
            let emoji: gameResultState = currentPlayer == .playerOne ? gameResultState.win : gameResultState.lose
           
            highlightButton(result.1)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.showMessageView(player + " win...", emoji)
            }
            return true
        } else {
            if draw() {
                showMessageView("Game draw.", .draw)
                return true
            } else {
                changePlayer()
                return false
            }
        }
    }
    
    private func showMessageView(_ message: String, _ result: gameResultState) {
        messageLabel.text = message
        UIView.transition(from: boardView, to: messageView, duration: 1.0, options: [.transitionFlipFromLeft, .showHideTransitionViews]) { (_) in
            
            if self.particleEmitter == nil {
                self.particleEmitter = CAEmitterLayer()
                self.createParticles(type: result)
            }
            self.particleEmitter.birthRate = 1.0
            self.resetPlayerStates()
        }
    }
    
    private func showBoardView() {
        UIView.transition(from: messageView, to: boardView, duration: 1.0, options: [.transitionFlipFromLeft, .showHideTransitionViews]) { (_) in
            self.particleEmitter.removeFromSuperlayer()
            self.particleEmitter = nil
        }
    }
    
    private func draw() -> Bool {
        return playersStates.filter({$0 == nil}).isEmpty
    }
    
    private func updatePlayerStates(index: Int) -> Bool {
        if index != -1, playersStates[index] == nil {
            playersStates[index] = currentPlayer.rawValue
            return true
        } else {
            return false
        }
    }
    
    func changePlayer() {
        switch currentPlayer {
        case .playerOne:
            currentPlayer = .computer
            //turnLabel.text = "My Turn"
        case .computer:
            currentPlayer = .playerOne
            //turnLabel.text = "Your Turn"
        }
    }
    
    func checkIfWinner(in tempState: [String?], player: Player) -> (Bool, [Int]) {
        var isWinner = false
        var winningState = [Int]()
        let winningConditions = [
            [0, 1, 2],
            [0, 4, 8],
            [0, 3, 6],
            [1, 4, 7],
            [2, 5, 8],
            [3, 4, 5],
            [6, 7, 8],
            [6, 4, 2]
        ]
        
        for winningStat in winningConditions {
            let result = winningStat.map({ (index) -> Bool in
                return tempState[index] == nil || tempState[index] != player.rawValue
            }).filter({$0 == true})
            
            if result.isEmpty {
                print("Winning sequence = \(winningStat)")
                isWinner = true
                winningState = winningStat
                break
            }
        }
        return (isWinner, winningState)
    }
    
    /// check if computer can win in given senario
    ///
    /// - Returns: return winning index if available else return -1
    func getWinningIndexForComputer() -> Int {
        
        if gameLevel.rawValue > DifficultyLevel.medium.rawValue , let playerWinningIndex = checkIfWin(player: Player.computer) {
            return playerWinningIndex
        } else if gameLevel.rawValue >= DifficultyLevel.medium.rawValue, let computerWinningIndex = checkIfWin(player: Player.playerOne) {
            return computerWinningIndex
        } else {
            let secureIndexes = [4, 0, 2, 6, 8, 3, 1, 5, 7]
            for index in secureIndexes {
                if playersStates[index] == nil {
                    return index
                }
            }
        }
        return -1
    }
    
    func checkIfWin(player: Player) -> Int? {
        var winnignIndex: Int?
        var tempStat = playersStates
        for (index, state) in tempStat.enumerated() {
            if state == nil {
                tempStat[index] = player.rawValue
                if checkIfWinner(in: tempStat, player: player).0 {
                    winnignIndex = index
                    print("win for index: \(index)")
                    break
                } else {
                    tempStat = playersStates
                    winnignIndex = nil
                }
            }
        }
        return winnignIndex
    }
    
    private func incrementScore(player: Player) {
        switch player {
        case .playerOne:
            playerOneScore += 1
        case .computer:
            computerScore += 1
        }
    }
}

//MARK: - Emiiter logic
extension ViewController {
    
    enum gameResultState: String {
        case win = "🥳"
        case lose = "😢"
        case draw = "😬"
    }
    
    func createParticles(type: gameResultState) {
        
        particleEmitter.emitterPosition = CGPoint(x: view.center.x, y: -96)
        particleEmitter.emitterShape = .line
        particleEmitter.emitterSize = CGSize(width: view.frame.size.width, height: 1)
        let cell = makeEmitterCell(type: type)
        particleEmitter.emitterCells = [cell]
        particleEmitter.lifetime = 2.0
        view.layer.addSublayer(particleEmitter)
    }
    
    func makeEmitterCell(type: gameResultState) -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = 20.0
        cell.lifetime = 2.0
        cell.lifetimeRange = 3.0
        //cell.color = color.cgColor
        cell.velocity = 200
        cell.velocityRange = 50
        cell.emissionLongitude = CGFloat.pi
        cell.emissionRange = CGFloat.pi / 4
        //cell.spin = 2
        cell.scale = 2.0
        //cell.spinRange = 3
        cell.scaleRange = 0.0
        cell.scaleSpeed = -0.05
        let image = generate(string:NSAttributedString(string: type.rawValue))
        cell.contents = image?.cgImage
        return cell
    }
    
    func generate(string: NSAttributedString) -> UIImage? {
        let particleSize = CGSize(width: 30, height: 30)
        let rect = CGRect(origin: CGPoint.zero, size: particleSize)
        UIGraphicsBeginImageContext(particleSize)
        if let currentContext = UIGraphicsGetCurrentContext() {
            currentContext.clear(rect)
            string.draw(in: rect)
            return UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        return nil
    }
}


