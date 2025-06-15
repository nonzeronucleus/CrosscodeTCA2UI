import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct CellReducer {
    enum Action: Equatable {
        case cellClicked(UUID)
    }
    
    var body: some Reducer<EditLayoutFeature.State, Action> {
        Reduce { state, action in
            switch action {
                case .cellClicked(let id):
                    return handleToggle(&state, id: id)
            }
        }
    }
    
    func handleToggle(_ state: inout EditLayoutFeature.State, id: UUID) -> Effect<Action> {
        guard !state.isPopulated, let level = state.layout,
              let location = level.crossword.locationOfElement(byID: id) else {
            return .none
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
        return .none
    }
}
