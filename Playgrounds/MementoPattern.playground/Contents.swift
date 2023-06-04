import UIKit

func example(of description: String, action: () -> Void) {
  print("\n--- Example of:", description, "---")
  action()
}

// The memento pattern is a Behavioral Pattern that allows an object to be saved and restored.
// This is a Behavioral pattern because this pattern is all about save and restoration behavior.
// It has three parts:
//
// ------------------   creates    ------------------            ------------------
// |                 |  and uses  |                 | persists |                 |
// |  Originator     |   ----->   |     Memento     |  <-----  |  Care Taker     |
// |_________________|            |_________________|          |_________________|
//
// 1- The originator is the object to be saved or restored.
// 2- The memento represents a stored state.
// 3- The caretaker requests a save from the originator and receives a memento in response. The caretaker is responsible for persisting the memento and, later on, providing the memento back to the originator to restore the originator’s state.


// While not strictly required, iOS apps typically use an Encoder to encode an originator’s state into a memento, and a Decoder to decode a memento back to an originator.
// This allows encoding and decoding logic to be reused across originators.
// For example, JSONEncoder and JSONDecoder allow an object to be encoded into and decoded from JSON data respectively.

// MARK: - When should you use it?
// - Use the memento pattern whenever you want to save and later restore an object’s state.
// - For example, you can use this pattern to implement a save game system, where the originator is the game state (such as level, health, number of lives, etc), the memento is saved data, and the caretaker is the gaming system.
// - You can also persist an array of mementos, representing a stack of previous states. You can use this to implement features such as undo/redo stacks in IDEs or graphics software.

// MARK: - Memento example
// Lets create a simple gaming system for this example.
// First, you need to define the originator

// MARK: - Originator

// Here, you define a Game:
// it has an internal State that holds onto game properties, and it has methods to handle in-game actions. You also declare Game and State conform to Codable.
final class Game: Codable {
    class State: Codable {
        var attemptsRemaining: Int = 3
        var level: Int = 1
        var score: Int = 0
    }
    var state = State()
    
    func rackUpMassivePoints() {
        state.score += 9002
    }
    
    func monstersEatPlayer() {
        state.attemptsRemaining -= 1
    }
}

// MARK: - What’s Codable? Great question!
// Apple introduced Codable in Swift 4. Any type that conforms to Codable can, in Apple’s words, “convert itself into and out of an external representation.” Essentially, it’s a type that can save and restore itself. Sound familiar? Yep, it’s exactly what you want the originator to be able to do.
// Since all of the properties that Game and State use already conform to Codable, the compiler automatically generates all required Codable protocol methods for you. String, Int, Double and most other Swift-provided types conform to Codable out of the box. How awesome is that?

// More formally, Codable is a typealias that combines the Encodable and Decodable protocols. It’s declared like this:

//      typealias Codable = Decodable & Encodable

// - Types that are Encodable can be converted to an external representation by an Encoder. The actual type of the external representation depends on the concrete Encoder you use. Fortunately, Foundation provides several default encoders for you, including JSONEncoder for converting objects to JSON data.
// - Types that are Decodable can be converted from an external representation by a Decoder. Foundation has you covered for decoders too, including JSONDecoder to convert objects from JSON data.

// MARK: - Memento
typealias GameMemento = Data

// Technically, you don’t need to declare this `GameMemento` line at all. Rather, it’s here to inform you the GameMemento is actually Data. This will be generated by the Encoder on save, and used by the Decoder on restoration.

// MARK: - CareTaker
final class GameSystem {
    // 1 - You first declare properties for decoder, encoder and userDefaults. You’ll use decoder to decode Games from Data, encoder to encode Games to Data, and userDefaults to persist Data to disk. Even if the app is re-launched, saved Game data will still be available.
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let userDefaults = UserDefaults.standard
    
    // 2 - save(_:title:) encapsulates the save logic. You first use encoder to encode the passed-in game. This operation may throw an error, so you must prefix it with try. You then save the resulting data under the given title within userDefaults.
    func save(_ game: Game, title: String) throws {
        let data = try encoder.encode(game)
        userDefaults.set(data, forKey: title)
    }
    
    // 3 - load(title:) likewise encapsulates the load logic. You first get data from userDefaults for the given title. You then use decoder to decode the Game from the data. If either operation fails, you throw a custom error for Error.gameNotFound. If both operations succeed, you return the resulting game.
    func load(title: String) throws -> Game {
        guard
            let data = userDefaults.data(forKey: title),
            let game = try? decoder.decode(Game.self, from: data)
        else {
            throw Error.gameNotFound
        }
        return game
    }
    
    enum Error: String, Swift.Error {
        case gameNotFound
    }
}

example(of: "Game system using Memento pattern") {
    // Here you simulate playing a game: the player gets eaten by a monster, but she makes a comeback and racks up massive points!
    var game = Game()
    print("Level:", game.state.level)
    print("Score:", game.state.score)
    print("Attempts remaining:", game.state.attemptsRemaining)
    game.monstersEatPlayer()
    game.rackUpMassivePoints()
    print("Gameplay")
    print("Score:", game.state.score)
    print("Attempts remaining:", game.state.attemptsRemaining)
    
    // Save Game
    let gameSystem = GameSystem()
    // Here, you simulate the player triumphantly saving her game, likely boasting to her friends shortly thereafter.
    do {
        try gameSystem.save(game, title: "Best Game Ever")
    } catch {
        print("Game did not save because \(error.localizedDescription)")
    }
    
    // Of course, she will want to try to beat her own record, so she’ll start a new Game.
    // New Game
    game = Game()
    print("New Game Score: \(game.state.score)") // This proves the default value is set for game.state.score.

    
    // Load Game
    // The player can also resume her previous game.
    do {
        game = try gameSystem.load(title: "Best Game Ever")
        print("Loaded Game Score: \(game.state.score)")
    } catch {
        print("Game could not be loaded \(error.localizedDescription)")
    }
}

// MARK: - What should you be careful about?
// - Be careful when adding or removing Codable properties: both encoding and decoding can throw an error. You will need to wrap the try in a do catch block, the catch will capture the error when you’re missing any required data.
// - Avoid using try! unless you’re absolutely sure the operation will succeed. You should also plan ahead when changing your models.
// - For example, you can version your models or use a versioned database. However, you’ll need to carefully consider how to handle version upgrades. You might choose to delete old data whenever you encounter a new version, create an upgrade path to convert from old to new data, or even use a combination of these approaches.

// MARK: - Here are its key points:
// - The memento pattern allows an object to be saved and restored. It involves three types: the originator, memento and caretaker.
// - The originator is the object to be saved; the memento is a saved state; and the caretaker handles, persists and retrieves mementos.
// - iOS provides Encoder for encoding a memento to, and Decoder for decoding from, a memento. This allows encoding and decoding logic to be used across originators.
