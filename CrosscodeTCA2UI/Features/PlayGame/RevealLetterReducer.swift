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
            case finished(Result<Int, Error>) // Num remaining letters to find
        }
    }
    
    var body: some Reducer<PlayGameFeature.State, Action> {
        Reduce { state, action in
            switch action {
                case let .api(externalActions):
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
                    return .run { [state] send in await send(.delegate(.finished(.success(state.usedLetters.count)))) }

                case .delegate:
                    return .none
            }
        }
    }
    
    func getNextLetterToReveal(state:State) async -> Result<(Character,Int), Error> {
        do {
            guard let char = state.level?.letterMap?.first(where: {
                let pos = $0.value
                let char = $0.key
                
                return !state.usedLetters.contains(char) && state.level?.attemptedLetters[pos] == " "
            }) else {
                throw RevealLetterError.noLettersLeft
            }
            return .success(char)
        } catch {
            return .failure(error)
        }
    }
    
    
}

enum RevealLetterError:Error, CustomStringConvertible, LocalizedError {
    case noLettersLeft
    
    public var description: String {
        switch self {
            case .noLettersLeft:
                return "No letters left"
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
