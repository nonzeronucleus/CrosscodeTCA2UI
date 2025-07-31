import Testing
@testable import CrosscodeTCA2UI
import ComposableArchitecture
import CrosscodeDataLibrary
import Factory

struct KeyboardFeatureTests {
    
    @Test func testAddLetterWithNoSelectedSquare() async throws {
        let store = await TestStore(
            initialState: PlayGameFeature.State(levelID:UUID(0), level: createLevel(charMap: "QWERTYUIOPASDFGHJKLZXCVBNM") )
        ) {
            KeyboardFeature()
        }
        
        // Nothing selected, so state shouldn't change
        await store.send(.view(.letterInput("Q")))
    }
    
    @Test func testAddLetterWithSelectedSquare() async throws {
        let store = await TestStore(
            initialState: PlayGameFeature.State(levelID:UUID(0), level: createLevel(charMap: "QWERTYUIOPASDFGHJKLZXCVBNM"), selectedNumber:2 )
        ) {
            KeyboardFeature()
        }
        
        // Third character (offset 0) selected, so that should be set to character
        await store.send(.view(.letterInput("Q"))) {
            $0.level!.attemptedLetters[2] = "Q"
        }

        await store.receive(\.delegate.finished)

        // Same one should be overwritten
        await store.send(.view(.letterInput("W"))) {
            $0.level!.attemptedLetters[2] = "W"
        }
        
        await store.receive(\.delegate.finished)
    }

    
        
//        {
//            $0.selectedNumber = 1
////            $0.usedLetters = ["Q"]
//        }
//        await store.send(.letterInput("A")) {
//            $0.usedLetters = ["A"]
//       }
//        await store.send(.letterInput("A"))
//        
//        await store.send(.letterSelectedInGrid("Q")) {
//        }
//        await store.send(.letterInput("Z")) {
//            $0.usedLetters = ["A", "Z"]
//        }
//        await store.send(.letterSelectedInGrid(nil)) {
//            $0.selectedLetterInGrid = nil
//        }
//        await store.send(.letterInput("T")) 
//
//    
//    @Test func testAddLetterThatsAlreadyBeenUsed() async throws {
//        let store = await TestStore(
//            initialState: PlayGameFeature.State(levelID:UUID(0), usedLetters:["A","B","C"], selectedLetterInGrid: "D")
//        ) {
//            KeyboardFeature()
//        }
////        await store.send(.keyboard(.letterInput("A"))) {
//        await store.send(.letterInput("A")) {
//            $0.usedLetters = ["A", "Z"]
//        }
//    }
}


fileprivate func createLevel(charMap: String) -> GameLevel {
    let layout = Layout(id: UUID(0), number: 1, crossword: Crossword(rows: 4, columns: 4), letterMap: CharacterIntMap(testMap:charMap))
    return GameLevel(layout: layout, id: UUID(0), number: 1, attemptedLetters: [Character](repeating: " ", count: 26))
//    return GameLevel(id: UUID(0), number: 1, packId: nil, letterMap: charMap)
}

public extension CharacterIntMap {
    init(testMap: String) {
        var charToIndex: [Character: Int] = [:]
        for (index, char) in testMap.enumerated() {
            charToIndex[char] = index // Overwrites duplicates!
        }
        self = charToIndex
    }
}
