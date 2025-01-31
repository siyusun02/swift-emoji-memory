//
//  Game.swift
//  Memory
//
//  Created by Si Yu Sun on 31.01.25.
//

import SwiftUI

class Game: ObservableObject {
    private let totalPairs: Int
    
    private var turned: [Int]
    private var turnBack: [Int] = []

    @Published var foundPairs: Int
    @Published var cards: [Card]
    @Published var tries: Int
    @Published var timeElapsed: Int

    var progress: Double {
        Double(foundPairs) / Double(totalPairs)
    }

    init(cards: [Card]) {
        if cards.count % 2 != 0 {
            fatalError("Invalid card count")
        }
        
        self.cards = cards
        self.totalPairs = cards.count / 2
        timeElapsed = 0
        foundPairs = 0
        tries = 0
        turned = []
        turnBack = []
    }

    static func createRandomGame(_ n: Int = 8) -> Game {
        var cards: [Card] = []
        
        var availableEmojis = Set(emojis)
        
        for _ in 0..<n {
            guard let emoji = availableEmojis.randomElement() else {
                print("Not enough emojis to pick from.")
                break
            }

            availableEmojis.remove(emoji) // remove to prevent duplicates
    
            let card = Card(
                id: -1,
                emoji: emoji,
                hidden: true
            )

            // add one pair
            cards.append(card)
            cards.append(card)
        }

        // shuffle and assign ids based on position
        cards.shuffle()
        for i in cards.indices {
            cards[i].id = i
        }
        
        return Game(cards: cards)
    }

    
    func turn(_ cardId: Int) {
        let card = cards[cardId]
        if !card.hidden {
            print("Card \(cardId) is already flipped!")
            return
        }
        
        // turn back from last round if needed
        if !turnBack.isEmpty {
            for i in turnBack {
                cards[i].hidden.toggle()
            }
            self.turnBack.removeAll()
        }
        
        // add current turn
        cards[cardId].hidden.toggle()
        turned.append(cardId)
        
        // check winning condition
        if turned.count >= 2 {
            self.tries += 1
            let card1 = cards[turned[0]]
            let card2 = cards[turned[1]]

            if card1.emoji == card2.emoji {
                // check if won
                foundPairs += 1
                print("yes :)")
            } else {
                // else turn back next round
                self.turnBack = turned
            }

            turned.removeAll()
        }
    }
}



