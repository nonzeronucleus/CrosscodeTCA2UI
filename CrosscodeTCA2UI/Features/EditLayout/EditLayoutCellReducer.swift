import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct EditLayoutCellReducer {
    enum Action: Equatable {
        case cellClicked(UUID)
        case delegate(Delegate)
        
        enum Delegate : Equatable {
            case failure(EquatableError)
        }
    }
    
    var body: some Reducer<EditLayoutFeature.State, Action> {
        Reduce { state, action in
            switch action {
                case .cellClicked(let id):
                    return handleToggle(&state, id: id)
                case .delegate:
                    return .none
            }
        }
    }
    
    func handleToggle(_ state: inout EditLayoutFeature.State, id: UUID) -> Effect<Action> {
        do {
            guard !state.isPopulated else {return .none} // If the layout has been populated with words, don't allow the cell to be clicked on
            guard let level = state.layout else { throw FeatureError.layoutNil}
            guard let location = level.crossword.locationOfElement(byID: id) else { throw FeatureError.couldNotFindCell(id)}
            
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
        catch {
            return .run {
                send in await send(.delegate(.failure(EquatableError(error))))
            }
        }
    }
    
    public enum FeatureError: Error {
        case layoutNil
        case couldNotFindCell(UUID)
    }
}

