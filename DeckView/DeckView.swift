//
//  DeckView.swift
//  DeckView
//
//  Created by bl4ckra1sond3tre on 7/11/16.
//  Copyright © 2016 bl4ckra1sond3tre. All rights reserved.
//

import UIKit

public typealias CardView = UIView

public protocol DeckViewDataSource: class {
    
    func numberOfCardInDeckView(deckView: DeckView) -> Int
    
    func deckView(deckView: DeckView, cardViewAt index: Int) -> CardView
}

public protocol DeckViewDelegate: class {
    
    func deckView(deckView: DeckView, didSelectAt index: Int)
}

private let defaultVisibleCount = 3
private let defaultDegree = CGFloat(-4.0 * M_PI) / 180.0

public class DeckView: UIView {
    
    public var visibleCount = defaultVisibleCount
    public var degree: CGFloat = defaultDegree
    public var faceColor: UIColor? = .whiteColor()
    public var deckedColor: UIColor = .clearColor()
    
    public weak var dataSource: DeckViewDataSource? {
        didSet {
            if dataSource != nil {
                configure()
            }
        }
    }
    public weak var delegate: DeckViewDelegate?
    
    // Queue
    private var visibleQueue: Queue<CardView> = Queue()
    private var reusableQueue: Queue<CardView> = Queue()
    
    private var cardViewType: AnyClass?
    
    private var candidateCardView: CardView {
        
        if let cardView = reusableQueue.dequeue() {
            reuse(cardView: cardView)
            return cardView
        } else {
            // allocate new
            let cardView = generate()
            reuse(cardView: cardView)
            return cardView
        }
    }
    
    override public func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        
        setup()
    }
    
    // MARK: - Private
    
    private func setup() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction(_:))))
    }
    
    @objc private func tapAction(sender: UITapGestureRecognizer) {
        
        guard let count = dataSource?.numberOfCardInDeckView(self) where count > 0 else { return }
        
        delegate?.deckView(self, didSelectAt: 0)
    }
    
    /// It will dellocate all memory cardView.
    private func resetDeck() {
        
        for cardView in visibleQueue.elements {
            cardView.removeFromSuperview()
        }
        visibleQueue.empty()
        
        for cardView in reusableQueue.elements {
            cardView.removeFromSuperview()
        }
        reusableQueue.empty()
    }

    private func configure() {
        
        guard let dataSource = dataSource else { return }
        
        let count = dataSource.numberOfCardInDeckView(self)
        
        let vacancyCount = count > visibleCount ? visibleCount : count
        
        for idx in 0..<vacancyCount {
            let cardView = dataSource.deckView(self, cardViewAt: idx)
            sendSubviewToBack(cardView) // ⚠️：send cardView to back
            visibleQueue.enqueue(cardView)
        }
        
        let headCardView = visibleQueue.peek()
        proper(cardView: headCardView)
    }
    
    private func generate() -> CardView {
        
        guard let cardViewType = cardViewType else {
            assert(false, "Must register cardView type with register(type:)")
            return CardView()
        }
        
        guard let cardView = (cardViewType as? CardView.Type)?.init() else {
            assert(false, "Can't initialize form type \(cardViewType)")
            return CardView()
        }
        
        addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[cardView]|", options: [], metrics: nil, views: ["cardView": cardView])
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[cardView]|", options: [], metrics: nil, views: ["cardView": cardView])
        NSLayoutConstraint.activateConstraints(hConstraints)
        NSLayoutConstraint.activateConstraints(vConstraints)
        
        return cardView
    }
    
    private func fillVisibleQueueIfNeeded() {
        
        let count = dataSource?.numberOfCardInDeckView(self) ?? 0
        
        if visibleQueue.count < visibleCount && visibleQueue.count < count {
            // Fill the queue
            let vacancyCount = visibleCount > count ? count - visibleQueue.count : visibleCount - visibleQueue.count
            
            let startIndex = visibleQueue.count
            
            for idx in 0..<vacancyCount {
                let cardView = dataSource!.deckView(self, cardViewAt: startIndex + idx)
                
                sendSubviewToBack(cardView)
                visibleQueue.enqueue(cardView)
            }
        }
    }
    
    private func proper(cardView cardView: CardView?) {
        UIView.animateWithDuration(0.2) {
            cardView?.transform = CGAffineTransformIdentity
            cardView?.layer.allowsEdgeAntialiasing = true
            cardView?.backgroundColor = self.faceColor
        }
    }
    
    private func reuse(cardView cardView: CardView?) {
        cardView?.transform = CGAffineTransformMakeRotation(degree)
        cardView?.layer.allowsEdgeAntialiasing = true
        cardView?.backgroundColor = deckedColor
        cardView?.alpha = 1.0
    }
    
    // MARK: Public
    
    /// Reload visible queue.
    public func reloadData() {
        resetDeck()
        configure()
    }
    
    /// Refresh visible cardView
    public func refreshData() {
        guard let dataSource = dataSource else { return }
        
        let count = visibleQueue.count
        for index in 0..<count {
            let cardView = dataSource.deckView(self, cardViewAt: index)
            visibleQueue.enqueue(cardView)
        }
        
        let headCardView = visibleQueue.peek()
        proper(cardView: headCardView)
    }

    public func register(type cardClass: AnyClass?) {
        cardViewType = cardClass
    }
    
    /*
    public func register(type cardClass: AnyClass?, forCardViewReuseIdentifier identifier: String) {
        cardViewTypeDictionary[identifier] = cardClass
    }
    
    public func dequeueCardView(with identifier: String, for index: Int) -> CardView {

        guard index < dataSource?.numberOfCardInDeckView(self) ?? 0 else {
            assert(false, "** deckView.dequeue(for:) **: overlay at index \(index)")
        }

        if (curIndex..<curIndex + visibleQueue.count).contains(index) {
            let cardView = visibleQueue.dequeue()!
            reuse(cardView: cardView)
            return cardView
        }
        return candidateCardView
    }
     */
    
    public func dequeueCardView(for index: Int) -> CardView {
        
        guard index < dataSource?.numberOfCardInDeckView(self) ?? 0 else {
            assert(false, "** deckView.dequeue(for:) **: overlay at index \(index)")
            return CardView()
        }

        if (0..<visibleQueue.count).contains(index) {
            let cardView = visibleQueue.dequeue()!
            reuse(cardView: cardView)
            return cardView
        }
        return candidateCardView
    }
    
    public func fadeOut(with animation: (cardView: CardView, completion: () -> Void) -> Void) {
        guard let headCardView = visibleQueue.dequeue() else { return }
        
        animation(cardView: headCardView) { [weak self] in
            guard let sSelf = self else { return }
            
            let count = sSelf.dataSource?.numberOfCardInDeckView(sSelf) ?? 0
            
            if 0 > count - sSelf.visibleCount {
                headCardView.removeFromSuperview()
            } else {
                
                sSelf.reuse(cardView: headCardView)
                // Sent to back
                sSelf.sendSubviewToBack(headCardView)
                sSelf.reusableQueue.enqueue(headCardView)
            }
            
            // Refill visible queue
            sSelf.fillVisibleQueueIfNeeded()
            
            // Proper head cardView
            let cardView = sSelf.visibleQueue.peek()
            sSelf.proper(cardView: cardView)
        }
    }
}

// MARK: - QUEUE
// LILO
struct Queue<T> {
    
    var isEmpty: Bool {
        return elements.isEmpty
    }
    
    var count: Int {
        return elements.count
    }
    
    mutating func enqueue(element: T) {
        elements.append(element)
    }
    
    mutating func dequeue() -> T? {
        if isEmpty {
            return nil
        } else {
            return elements.removeFirst()
        }
    }
    
    func peek() -> T? {
        return elements.first
    }
    
    mutating func empty() {
        elements.removeAll()
    }
    
    private(set) var elements = [T]()
}
