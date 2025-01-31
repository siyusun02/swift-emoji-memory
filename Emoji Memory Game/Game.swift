//
//  Game.swift
//  Memory
//
//  Created by Si Yu Sun on 31.01.25.
//

import SwiftUI

enum ScoreFactors {
    static let weightTries = 2.0
    static let weightTime = 1.0
    static let scalingFactor = 1000.0
}

class Game: ObservableObject {
    private var totalPairs: Int
    private var turned: [Int]
    private var turnBack: [Int]
    private var timer: Timer?

    @Published var foundPairs: Int
    @Published var cards: [Card]
    @Published var tries: Int
    @Published var timeElapsed: Int
    @Published var won: Bool

    var progress: Double {
        Double(foundPairs) / Double(totalPairs)
    }

    func calculateScore() -> Int {
        /*
         Score is calculated with a weighted formula:
         - Fewer tries -> Much higher score (weighted more heavily)
         - Less time -> Still improves score, but less impact
         - +1 in time prevents division by zero
         - Scaling factor keeps numbers reasonable
        */
        let score =
            ScoreFactors.scalingFactor
            * (ScoreFactors.weightTries / Double(tries) + ScoreFactors
                .weightTime / Double(timeElapsed + 1))
        return Int(score.rounded())
    }

    init() {
        (
            cards, totalPairs, timeElapsed, foundPairs, tries, turned, turnBack,
            timer, won
        ) = Game.createNewGame()
    }

    func restart() {
        (
            cards, totalPairs, timeElapsed, foundPairs, tries, turned, turnBack,
            timer, won
        ) = Game.createNewGame()
    }

    private static func createNewGame(_ n: Int = 8) -> (
        [Card], Int, Int, Int, Int, [Int], [Int], Timer?, Bool
    ) {
        return (Game.createRandomCards(n), n, 0, 0, 0, [], [], nil, false)
    }

    static func createRandomCards(_ n: Int) -> [Card] {
        var cards: [Card] = []

        var availableEmojis = Set(emojis)

        for _ in 0..<n {
            guard let emoji = availableEmojis.randomElement() else {
                print("Not enough emojis to pick from.")
                break
            }

            availableEmojis.remove(emoji)  // remove to prevent duplicates

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

        return cards
    }

    func turn(_ cardId: Int) {
        if timeElapsed == 0 {
            timeElapsed = 1
            self.timer = Timer.scheduledTimer(
                withTimeInterval: 1.0,
                repeats: true
            ) { timer in
                self.timeElapsed += 1
            }
        }

        // check if card has been flipped
        let card = cards[cardId]
        if !card.hidden {
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
                if foundPairs == totalPairs {
                    guard let t = self.timer else {
                        fatalError("Timer unexpected not initialized")
                    }

                    t.invalidate()
                    self.won = true
                }
            } else {
                // else turn back next round
                self.turnBack = turned
            }

            turned.removeAll()
        }
    }
}
