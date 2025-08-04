import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct RevealLetterReducer {
    typealias State = PlayGameFeature.State
    @Dependency(\.apiClient) var apiClient
    
    @CasePathable
    enum Action {
        case api(API)
        case `internal`(Internal)
        case delegate(Delegate)
        
        @CasePathable
        enum API {
            case start
        }
        
        @CasePathable
        enum Internal  {
            case finished(Result<(Character,Int), Error>)
        }
        
        @CasePathable
        enum Delegate {
            case finished(Result<Void, Error>) // Num remaining letters to find
        }
    }
    
    var body: some Reducer<PlayGameFeature.State, Action> {
        Reduce { state, action in

            switch action {
                case let .api(externalActions):
                    if state.isCompleted {return .none}

                    switch externalActions {
                        case .start:
                            return .run { [state] send in
                                let result = await getNextLetterToReveal(state: state)
                                await send(.internal(.finished(result)))
                            }
                    }
                    
                case .internal(.finished(let result)):
                    switch result {
                        case .success((let letter, let idx)):
                            state.level?.attemptedLetters[idx] = letter
                            break
                            
                        case .failure:
                            break
                    }
                    return .run { send in await send(.delegate(.finished(.success(())))) }

                case .delegate:
                    return .none
            }
        }
    }
    
    // Get the first letter that hasn't been used (correctly or incorrectly) and whose correct value hasn't been taken by an incorrect guess
    func getNextLetterToReveal(state:State) async -> Result<(Character,Int), Error> {
        do {
//            guard let letterMap = state.level?.oldLetterMap else { throw RevealLetterError.noLetterMap }
            guard let char = try state.level!.getNextLetter()
            else {
                throw RevealLetterError.noLettersLeft
            }
            return .success(char)
        } catch {
            return .failure(error)
        }
    }
}



//            guard let char = state.level?.letterMap?.first(where: {
//                let pos = $0.value
//                let char = $0.key
//
//                return !state.usedLetters.contains(char) && state.level?.attemptedLetters[pos] == " "

//func getNextLetter(letterMap:[Character], usedLetters: Set<Character>, attemptedLetters:[Character]) throws -> (Character, Int)?  {
//    guard let char = letterMap.first(where: {
//        let pos = $0.value
//        let char = $0.key
//        
//        return !usedLetters.contains(char) && attemptedLetters[pos] == " "
//    }) else {
//        return nil
//    }
//    
//    return char
//}
//
//

//
//func getNextLetter(letterMap:[Character], attemptedLetters:[Character]) throws -> (Character, Int)?  {
//    let unusedLetters = getUnusedLetters(letterMap: letterMap, attemptedLetters: attemptedLetters)
//    
//    
//    let availableLetters = unusedLetters.enumerated()
//        .compactMap { (index, char) -> (Character, Int)? in
//            guard let char = char else { return nil }
//            return (char, index)
//        }
//    
//    // 2. Return random element if exists
//    return availableLetters.randomElement()
//
//}

//
//func getUnusedLetters(letterMap: [Character], attemptedLetters: [Character?]) -> [Character?] {
//    guard letterMap.count == 26 && attemptedLetters.count == 26 else {
//        fatalError("Arrays must be 26 characters long")
//    }
//    
//    // 1. Get all non-nil attempted letters
//    let usedLetters = Set(attemptedLetters.compactMap { $0 })
//    
//    // 2. Create masked array preserving positions
//    return letterMap.enumerated().map { index, letter in
//        // Keep letter if:
//        // - Position in attemptedLetters is nil (not attempted)
//        // - Letter isn't used elsewhere
//        attemptedLetters[index] == " " && !usedLetters.contains(letter)
//        ? letter
//        : nil
//    }
//}


enum RevealLetterError:Error, CustomStringConvertible, LocalizedError {
    case noLettersLeft
    case noLetterMap

    public var description: String {
        switch self {
            case .noLettersLeft:
                return "No letters left"
            case .noLetterMap:
                return "No letter map"
        }
    }
    
    // LocalizedError conformance for better UIKit/SwiftUI integration
    public var errorDescription: String? {
        return description
    }
    
    public var localizedDescription: String {
        return description
    }
}
