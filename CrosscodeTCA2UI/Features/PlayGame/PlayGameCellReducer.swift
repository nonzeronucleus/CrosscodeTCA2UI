import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct PlayGameCellReducer {
    enum Action {
        case cellClicked(UUID)
        case letterSelected(Character)
        case failure(Error)
    }
    
    var body: some Reducer<PlayGameFeature.State, Action> {
        Reduce { state, action in
            switch action {
                case .cellClicked(let id):
                    return handleSelect(&state, id: id)
                case .letterSelected(_):
                    return .none
                case .failure(_):
                    return .none
            }
        }
    }
    
    func handleSelect(_ state: inout PlayGameFeature.State, id: UUID) -> Effect<Action> {
        guard let level = state.level else {return .run { send in await send(.failure(FeatureError.levelNil))}}
        guard
            let cell = level.crossword.findElement(byID: id),
            let letter = cell.letter,
            let number = level.letterMap?[letter]
        else { return .none }
        
        state.selectedNumber = number
        return .run { send in
            await send(.letterSelected(level.attemptedLetters[number]))
        }
    }
    
    public enum FeatureError: Error {
        case levelNil
        case couldNotFindCell(UUID)
    }
}

