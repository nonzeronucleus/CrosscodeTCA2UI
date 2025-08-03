//
//  PlayGameKeyboardTests.swift
//  CrosscodeTCA2UI
//
//  Created by Ian Plumb on 03/08/2025.
//
import Testing
@testable import CrosscodeTCA2UI
import ComposableArchitecture
import CrosscodeDataLibrary
import Factory

//, attemptedLetters:  "QWERTYUIOPASDFGHJKLZXCVBN "

struct PlayGameCompletedTests {
    
    @Test func testCompletingCorrectLetters() async throws {
        let store = await TestStore(
            initialState: PlayGameFeature.State(levelID:UUID(0), level: createLevel(charMap: "QWERTYUIOPASDFGHJKLZXCVBNM", attemptedLetters: "QWERTYUIOPASDFGHJKLZXCVBN "), selectedNumber:2 )
        ) {
            PlayGameFeature()
        }
        
        await #expect(store.state.isCompleted == false)
        
        await store.send(.revealLetterReducer(.api(.start)))
        
        await store.receive(\.revealLetterReducer.internal.finished){
            $0.level!.attemptedLetters[25] = "M"
        }
        await store.receive(\.revealLetterReducer.delegate.finished)
        
        await #expect(store.state.isCompleted == true)
    }
    
    @Test func testAlreadyComplete() async throws {
        let store = await TestStore(
            initialState: PlayGameFeature.State(levelID:UUID(0), level: createLevel(charMap: "QWERTYUIOPASDFGHJKLZXCVBNM", attemptedLetters: "QWERTYUIOPASDFGHJKLZXCVBNM"), selectedNumber:2 )
        ) {
            PlayGameFeature()
        }
        
        await #expect(store.state.isCompleted == true)
    }

    @Test func testPopulatedAndWrong() async throws {
        let store = await TestStore(
            initialState: PlayGameFeature.State(levelID:UUID(0), level: createLevel(charMap: "QWERTYUIOPASDFGHJKLZXCVBNM", attemptedLetters: "QWERTYUIOPASDFGHJKLZXCVBMN"), selectedNumber:2 )
        ) {
            PlayGameFeature()
        }
        
        await #expect(store.state.isCompleted == false)
    }
}


fileprivate func createLevel(charMap: String, attemptedLetters: String) -> GameLevel {
    let layout = Layout(id: UUID(0), number: 1, crossword: Crossword(rows: 4, columns: 4), letterMap: charMap)
    return GameLevel(layout: layout, id: UUID(0), number: 1, attemptedLetters:Array(attemptedLetters))
}

