import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct EditLayoutFeature {
    @Dependency(\.uuid) var uuid
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.isPresented) var isPresented

    @ObservableState
    struct State: Equatable {
        var layoutID: UUID
        var layout: Layout?
        var isBusy = false
        var isPopulated: Bool = false
        var error: EquatableError?
    }

    enum Action: Equatable {
        case pageLoaded
        case backButtonTapped
        
        case loadLayout(LoadLayoutReducer.Action)
        case populate(PopulationReducer.Action)
        case depopulate(DepopulationReducer.Action)
        case cell(CellReducer.Action)
        case failure(EquatableError)
    }
    
    var body: some Reducer<State, Action> {
        
        Scope(state: \.self, action: \.loadLayout) { LoadLayoutReducer() }
        Scope(state: \.self, action: \.cell) { CellReducer() }
        Scope(state: \.self, action: \.populate) { PopulationReducer() }
        Scope(state: \.self, action: \.depopulate) { DepopulationReducer() }
        


        
        Reduce { state, action in
            switch action {
                case .backButtonTapped:
                    if isPresented {
                        return .run { _ in
                            await dismiss()
                        }
                    } else {
                        return .none
                    }
                case .pageLoaded:
                    return .send(.loadLayout(.start(state.layoutID)))
                    
                case .failure(let error):
                    return handleError(&state, error: error)
                    
                    // Mark - Loading
                case .loadLayout(.failure(let error)):
                    return handleError(&state, error: error)
                case .loadLayout(_):
                    return .none
                    
                    // Mark - Cell
                case .cell(_):
                    return .none
                    
                    // Mark - Population
                case .populate(.failure(let error)):
                    return handleError(&state, error: error)
                case .populate(_):
                    return .none
                    
                    //Mark - Depopulation
                case .depopulate(.failure(let error)):
                    return handleError(&state, error: error)
                case .depopulate(_):
                    return .none
            }
        }
    }
    
    func handleError(_ state: inout State, error: EquatableError) -> Effect<Action> {
        state.error = error
        state.isBusy = false
        return .none
    }
}

func handleToggle(_ state: inout EditLayoutFeature.State, id: UUID) -> Effect<EditLayoutFeature.Action> {
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



public enum EditLayoutError: Error {
    case loadLayoutError
    case handlePopulationError(_ text:String)
}
