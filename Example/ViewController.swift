//
//  ViewController.swift
//  Example
//
//  Created by bl4ckra1sond3tre on 7/13/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit
import DeckView

struct PlayingCard {
    let suit: String
    let rank: String
    
    static var validSuits: [String] {
        return ["♠", "♥", "♣", "♦"]
    }
    
    static var validRanks: [String] {
        return Array(1...13).map {
            if $0 == 1 { return "A" }
            if $0 == 11 { return "J" }
            if $0 == 12 { return "Q" }
            if $0 == 13 { return "K" }
            else { return "\($0)" }
        }
    }
}

final class PlayingCardView: CardView {
    
    lazy var rankingLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(white: 1.0, alpha: 1.0)
        label.textAlignment = .Left
        return label
    }()
    lazy var suitLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(white: 1.0, alpha: 1.0)
        label.textAlignment = .Right
        return label
    }()
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(superview)
        
        setup()
    }
    
    private func setup() {
        addSubview(rankingLabel)
        addSubview(suitLabel)
        rankingLabel.translatesAutoresizingMaskIntoConstraints = false
        suitLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let views = [
            "rankingLabel": rankingLabel,
            "suitLabel": suitLabel,
        ]
        
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-12-[rankingLabel]-(>=10)-[suitLabel]-12-|", options: [], metrics: nil, views: views)
        
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-12-[rankingLabel]-(>=10)-[suitLabel]-12-|", options: [], metrics: nil, views: views)
        
        NSLayoutConstraint.activateConstraints(hConstraints)
        NSLayoutConstraint.activateConstraints(vConstraints)
    }
}

final class ViewController: UIViewController {
    
    @IBOutlet weak var deckView: DeckView!
    private let degree = CGFloat(-8.0 * M_PI) / 180.0
    private var cards = [PlayingCard]()
    
    private func generate() -> [PlayingCard] {
        
        var cards = [PlayingCard]()
        for suit in PlayingCard.validSuits {
            for rank in PlayingCard.validRanks {
                cards.append(PlayingCard(suit: suit, rank: rank))
            }
        }
        
        return cards
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        deckView.register(type: PlayingCardView.self)
        deckView.faceColor = UIColor(hue:0.50, saturation:0.78, brightness:0.73, alpha:1.00)
        deckView.deckedColor = UIColor(hue: 0.98, saturation: 0.51, brightness: 1.00, alpha: 1.00)
        deckView.delegate = self
        deckView.dataSource = self
    }

    @IBAction private func restartAction(sender: UIButton) {
        cards.removeAll()
        
        cards = generate()
        deckView.reloadData()
    }
    
    @IBAction private func shuffleAction(sender: AnyObject) {
        cards = cards.shuffle()
        
        deckView.reloadData()
    }
}

extension ViewController: DeckViewDataSource {
    
    func numberOfCardInDeckView(deckView: DeckView) -> Int {
        return cards.count
    }
    
    func deckView(deckView: DeckView, cardViewAt index: Int) -> CardView {
        guard let playingCardView = deckView.dequeueCardView(for: index) as? PlayingCardView, card = cards[safe: index] else {
            return CardView()
        }
        
        playingCardView.rankingLabel.text = card.rank
        playingCardView.suitLabel.text = card.suit
        return playingCardView
    }
}

extension ViewController: DeckViewDelegate {
    
    func deckView(deckView: DeckView, didSelectAt index: Int) {
        guard !cards.isEmpty else {
            return
        }
        
        cards.removeFirst()
        deckView.fadeOut { [weak self] (cardView, completion) in
            guard let sSelf = self else { return }
            UIView.animateWithDuration(0.3, animations: {
                cardView.transform = CGAffineTransformMakeRotation(-sSelf.degree * 2)
                cardView.alpha = 0.0
            }, completion: { (finished) in
                completion()
                cardView.alpha = 1.0
            })
        }
    }
}

extension CollectionType {
    
    subscript(safe index: Index) -> Generator.Element? {
        return indices.contains(index) ? self[index] : .None
    }
    
    func shuffle() -> [Generator.Element] {
        return sort() { lhs, rhs in
            return arc4random() < arc4random()
        }
    }
}
