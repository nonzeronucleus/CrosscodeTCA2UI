import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct PlayGameCellReducer {
    @CasePathable
    enum Action {
        case cellClicked(UUID)
        case letterSelected(Character)
        case `internal`(Internal)
        
        @CasePathable
        enum Internal {
            case finished(Result<Int, Error>) // Num remaining letters to find
        }
        
//        case failure(Error)
    }
    
    var body: some Reducer<PlayGameFeature.State, Action> {
        Reduce { state, action in
            switch action {
                case .cellClicked(let id):
                    return .run { [state] send in
                        let result = await handleSelect(state, id: id)
                        await send(.internal(.finished(result)))
                    }
                case .letterSelected(_):
                    return .none
                case .internal(.finished(.success(let selectedNumber))):
                    state.selectedNumber = selectedNumber
                    return .none
                case .internal(.finished(.failure(_))):
                    return .none
            }
        }
    }
    
    func handleSelect(_ state: PlayGameFeature.State, id: UUID) async -> Result<Int, Error> {
        guard let level = state.level else {return .failure(FeatureError.levelNil)}
        guard
            let cell = level.crossword.findElement(byID: id),
            let letter = cell.letter,
            let number = indexOfLetter(letter, in: level.letterMap)   //level.letterMap[letter]
        else { return .failure(FeatureError.couldNotFindCell(id)) }
        
        return .success(number)
            
//            .run { send in
//            await send(.letterSelected(level.attemptedLetters[number]))
//        }
    }
    
    func indexOfLetter(_ letter: Character, in chars: [Character]) -> Int? {
        chars.firstIndex(of: letter) // Returns nil if not found
    }
    
    public enum FeatureError: Error {
        case levelNil
        case couldNotFindCell(UUID)
    }
}

