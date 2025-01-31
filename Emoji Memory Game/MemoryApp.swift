import SwiftUI

@main
struct MemoryApp: App {
    @StateObject private var game: Game = Game.createRandomGame()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(game)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Game.createRandomGame())
    }
}
