import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct EditLayoutCellReducer {
    typealias State = EditLayoutFeature.State

    @CasePathable
    enum Action: Equatable {
        case view(View)
        case delegate(Delegate)
        
        @CasePathable
        enum View: Equatable {
            case cellClicked(UUID)
        }
        
        @CasePathable
        enum Delegate : Equatable {
            case failure(EquatableError)
        }
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                case let .view(viewAcion):
                    return handleViewAction(&state, viewAcion)
                case .delegate:
                    return .none
            }
        }
    }
    

    public enum FeatureError: Error {
        case layoutNil
        case couldNotFindCell(UUID)
    }
}

private extension EditLayoutCellReducer {
    // MARK: View Actions
    func handleViewAction(_ state: inout State, _ action: Action.View) -> Effect<Action> {
        switch action {
            case .cellClicked(let id):
                return handleToggle(&state, id: id)
        }
    }
    
    func handleToggle(_ state: inout State, id: UUID) -> Effect<Action> {
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
}

