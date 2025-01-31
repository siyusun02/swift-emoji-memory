//
//  ContentView.swift
//  Emoji Memory Game
//
//  Created by Si Yu Sun on 31.01.25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var game: Game

    @State private var didError = true

    private let cols = Array(repeating: GridItem(.flexible()), count: 4)

    func formattedTime(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("Emoji Memory ").font(.largeTitle)

            HStack {
                Label(
                    "Time: \(formattedTime(game.timeElapsed))",
                    systemImage: "clock")
                Label(
                    "Turns: \(game.tries)",
                    systemImage: "rectangle.on.rectangle")
                Label("Found: \(game.foundPairs)", systemImage: "flag")
            }

            ProgressView(value: game.progress).tint(.red)

            LazyVGrid(columns: cols) {
                ForEach(game.cards) {
                    CardView(card: $0)
                }
            }.padding(.horizontal)

            Spacer()
        }.alert(
            "You did it! 🥳🎉",
            isPresented: $game.won,
            presenting: game
        ) { game in
            Button("Try Again", role: .cancel) {
                game.restart()
            }
        } message: { game in
            Text(
                """
                ---------------
                🎯 Final Score: \(game.calculateScore())
                ---------------
                Is based on your final stats.
                ⏳ Time: \(formattedTime( game.timeElapsed))
                🔄 Turns: \(game.tries)
                
                Can you beat your highscore? 🤔
                """
            )
        }
    }
}

struct CardView: View {
    @EnvironmentObject var game: Game
    let card: Card

    var body: some View {
        Button {
            game.turn(card.id)
        } label: {
            Text(card.hidden ? "🫢" : String(card.emoji)).font(.system(size: 64))
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
                .aspectRatio(contentMode: .fit)
                .background(card.hidden ? .red : .white)
                .border(.red)
                .cornerRadius(4)

        }
    }
}
