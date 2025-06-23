import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct PlayGameCellReducer {
    enum Action: Equatable {
        case cellClicked(UUID)
        case letterSelected(Character)
        case failure(EquatableError)
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
        guard let level = state.level else {return .run { send in await send(.failure(EquatableError(FeatureError.levelNil)))}}
        guard
            let cell = level.crossword.findElement(byID: id),
            let letter = cell.letter,
            let number = level.letterMap?[letter]
        else { return .none }
        
        state.selectedNumber = number
        debugPrint("Selected number: \(number),  letter \(level.attemptedLetters[number])")
        
        return .run { send in
            await send(.letterSelected(level.attemptedLetters[number]))
        }

        
//
        
//        guard let level = state.layout else {return .run { send in await send(.failure(EquatableError(FeatureError.layoutNil)))}}
        
//        guard !state.isPopulated else {return .none} // If the layout has been populated with words, don't allow the cell to be clicked on
//        guard let location = level.crossword.locationOfElement(byID: id) else {return .run { send in await send(.failure(EquatableError(FeatureError.couldNotFindCell(id))))}
//        }
//        
//        // Calculate opposite position first
//        let opposite = Pos(
//            row: level.crossword.columns - 1 - location.row,
//            column: level.crossword.rows - 1 - location.column
//        )
//        
//        // Minimize update calls
//        var crossword = level.crossword
//        crossword.updateElement(byPos: location) { $0.toggle() }
//        if opposite != location {
//            crossword.updateElement(byPos: opposite) { $0.toggle() }
//        }
//        
//        state.layout = level.withUpdatedCrossword(crossword)
//        state.isDirty = true

//        return .none
    }
    
    public enum FeatureError: Error {
        case levelNil
        case couldNotFindCell(UUID)
    }
}

