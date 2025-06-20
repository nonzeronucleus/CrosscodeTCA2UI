import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct EditLayoutCellReducer {
    enum Action: Equatable {
        case cellClicked(UUID)
        case failure(EquatableError)
    }
    
    var body: some Reducer<EditLayoutFeature.State, Action> {
        Reduce { state, action in
            switch action {
                case .cellClicked(let id):
                    return handleToggle(&state, id: id)
                case .failure(_):
                    return .none
            }
        }
    }
    
    func handleToggle(_ state: inout EditLayoutFeature.State, id: UUID) -> Effect<Action> {
        guard !state.isPopulated else {return .none} // If the layout has been populated with words, don't allow the cell to be clicked on
        guard let level = state.layout else {return .run { send in await send(.failure(EquatableError(EditLayoutCellReducerError.layoutNil)))}}
        guard let location = level.crossword.locationOfElement(byID: id) else {return .run { send in await send(.failure(EquatableError(EditLayoutCellReducerError.couldNotFindCell(id))))}
        }
        
        // Calculate opposite position first
        let opposite = Pos(
            row: level.crossword.columns - 1 - location.row,
            column: level.crossword.rows - 1 - location.column
        )
        
        // Minimize update calls
        var crossword = level.crossword
        crossword.updateElement(byPos: location) { $0.toggle() }
        if opposite != location {
            crossword.updateElement(byPos: opposite) { $0.toggle() }
        }
        
        state.layout = level.withUpdatedCrossword(crossword)
        state.isDirty = true

        return .none
    }
}

public enum EditLayoutCellReducerError: Error {
    case layoutNil
    case couldNotFindCell(UUID)
}
