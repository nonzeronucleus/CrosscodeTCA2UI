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
    
    
    @Test func testAddLetterWithMultipleSelectedSquares() async throws {
        let store = await TestStore(
            initialState: PlayGameFeature.State(levelID:UUID(0), level: createLevel(charMap: "QWERTYUIOPASDFGHJKLZXCVBNM"), selectedNumber:2 )
        ) {
            PlayGameFeature()
        }
        
        // Third character (offset 0) selected, so that should be set to character
        await store.send(.keyboard(.view(.letterInput("Q")))) {
            $0.level!.attemptedLetters[2] = "Q"
        }
        
        await store.receive(\.keyboard.delegate.finished)
        
        await store.send(.playGameCell(.internal(.finished(.success(3))))) { state in // Seleect cell numbered 3
            state.selectedNumber = 3
        }
        
        await store.send(.keyboard(.view(.letterInput("Q")))) {
            $0.level!.attemptedLetters[2] = " "
            $0.level!.attemptedLetters[3] = "Q"
        }
        
        await store.receive(\.keyboard.delegate.finished)
    }
    
    @Test func testDeleteLetter() async throws {
        let store = await TestStore(
            initialState: PlayGameFeature.State(levelID:UUID(0), level: createLevel(charMap: "QWERTYUIOPASDFGHJKLZXCVBNM"), selectedNumber:2 )
        ) {
            PlayGameFeature()
        }
        
        // Third character (offset 0) selected, so that should be set to character
        await store.send(.keyboard(.view(.letterInput("Q")))) {
            $0.level!.attemptedLetters[2] = "Q"
        }
        
        await store.receive(\.keyboard.delegate.finished)
        
        await store.send(.playGameCell(.internal(.finished(.success(3))))) { state in // Seleect cell numbered 3
            state.selectedNumber = 3
        }
        
        await store.send(.keyboard(.view(.letterInput("A")))) {
            $0.level!.attemptedLetters[3] = "A"
        }
        
        await store.receive(\.keyboard.delegate.finished)
        
        await store.send(.playGameCell(.internal(.finished(.success(2))))) { state in // Seleect cell numbered 2 again - which should have Q in it
            state.selectedNumber = 2
        }
        
        await store.send(.keyboard(.view(.deleteInput))) {
            $0.level!.attemptedLetters[2] = " "
        }
        
        await store.receive(\.keyboard.delegate.finished)

    }
}


fileprivate func createLevel(charMap: String) -> GameLevel {
    let layout = Layout(id: UUID(0), number: 1, crossword: Crossword(rows: 4, columns: 4), letterMap: charMap)  //letterMap: CharacterIntMap(testMap:charMap))
    return GameLevel(layout: layout, id: UUID(0), number: 1, attemptedLetters: [Character](repeating: " ", count: 26))
//    return GameLevel(id: UUID(0), number: 1, packId: nil, letterMap: charMap)
}

