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
        var isExiting: Bool = false
        var error: EquatableError?
    }

    enum Action: Equatable {
        case pageLoaded
        case backButtonTapped
        
        case loadLayout(LoadLayoutReducer.Action)
        case saveLayout(SaveLayoutReducer.Action)
        case populate(PopulationReducer.Action)
        case depopulate(DepopulationReducer.Action)
        case cell(EditLayoutCellReducer.Action)
        case failure(EquatableError)
    }
    
    var body: some Reducer<State, Action> {
        
        Scope(state: \.self, action: \.loadLayout) { LoadLayoutReducer() }
        Scope(state: \.self, action: \.saveLayout) { SaveLayoutReducer() }
        Scope(state: \.self, action: \.cell) { EditLayoutCellReducer() }
        Scope(state: \.self, action: \.populate) { PopulationReducer() }
        Scope(state: \.self, action: \.depopulate) { DepopulationReducer() }
        
        Reduce { state, action in
            switch action {
                case .backButtonTapped:
                    if isPresented {
                        state.isExiting = true
                        if state.isPopulated {
                            return .run { _ in
                                debugPrint("Need to implement handler for population exit here.")
                                await dismiss()
                            }
                        }
 
                        return .send(.saveLayout(.start))
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
                case .cell(.failure(let error)):
                    return handleError(&state, error: error)
                case .cell(.cellClicked(_)):
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

                case .saveLayout(.success):
                    if state.isExiting {
                        return .run { _ in
                            await dismiss()
                        }
                    } else {
                        return .none
                    }

                case .saveLayout(.failure(let error)):
                    state.isExiting = false
                    return handleError(&state, error: error)
                case .saveLayout(_):
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


public enum EditLayoutError: Error {
    case loadLayoutError
    case saveLayoutError(_ text:String)
    case handlePopulationError(_ text:String)
}
