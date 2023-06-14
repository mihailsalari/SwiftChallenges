import UIKit
// https://www.hackingwithswift.com/articles/258/whats-new-in-swift-5-9

func example(of description: String, action: () -> Void) {
    print("\n--- Example of:", description, "---")
    action()
}

// the 5.x releases still have a lot to give – simpler ways to use if and switch, macros, noncopyable types, custom actor executors, and more are all coming in Swift 5.9, making yet another mammoth release.



// MARK: - if let predicate

// MARK: - macros


// #predicate
struct Person {
    let name: String
    let age: Int
    let favColour: UIColor
}

//let pred = #Predicate<Person> {
//    $0.favColour == .blue
//}
//let blueColors = people.filter(pred)

// #swiftstrings

// @CaseDetection

// @observable

// @Model
