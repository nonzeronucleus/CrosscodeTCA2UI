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
        var settings = Settings()
        var layoutID: UUID
        var layout: Layout?
        var isBusy = false
        var isDirty = false
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
                case .pageLoaded:
                    return handlePageLoaded(&state)
                    
                case .backButtonTapped:
                    return handleBackButton(&state)
                    
                case .failure(let error):
                    return handleError(&state, error: error)

                case let .loadLayout(.delegate(action)):
                    return handleLoadLayoutDelegate(&state, action)
                    
                case let .saveLayout(.delegate(action)):
                    return handleSaveLayoutDelegate(&state, action)

                case let .cell(.delegate(action)):
                    return handleCellDelegate(&state, action)

                case let .populate(.delegate(action)):
                    return handlePopulationDelegate(&state, action)

                case let .depopulate(.delegate(action)):
                    return handleDepopulationDelegate(&state, action)

                case .saveLayout, .populate, .depopulate, .loadLayout, .cell:
                    return .none
            }
        }
    }
    
    func handlePageLoaded(_ state: inout State) -> Effect<Action> {
        return .send(.loadLayout(.start(state.layoutID)))
    }
    
    func handleBackButton(_ state: inout State) -> Effect<Action> {
        if isPresented {
            state.isExiting = true
            if state.isPopulated {
                return .run { _ in await dismiss() }
            }

            return .send(.saveLayout(.start))
        } else {
            return .none
        }
    }
    
    
    private func handleLoadLayoutDelegate(_ state: inout State,_ action: LoadLayoutReducer.Action.Delegate) -> Effect<Action> {
        switch action {
            case .failure(let error):
                return handleError(&state, error: error)
        }
    }

    private func handleCellDelegate(_ state: inout State,_ action: EditLayoutCellReducer.Action.Delegate) -> Effect<Action> {
        switch action {
            case .failure(let error):
                return handleError(&state, error: error)
        }
    }

    private func handlePopulationDelegate(_ state: inout State,_ action: PopulationReducer.Action.Delegate) -> Effect<Action> {
        switch action {
            case .failure(let error):
                return handleError(&state, error: error)
        }
    }
    
    private func handleDepopulationDelegate(_ state: inout State,_ action: DepopulationReducer.Action.Delegate) -> Effect<Action> {
        switch action {
            case .failure(let error):
                return handleError(&state, error: error)
        }
    }


    private func handleSaveLayoutDelegate(_ state: inout State,_ action: SaveLayoutReducer.Action.Delegate) -> Effect<Action> {
        switch action {
            case .success:
                state.isBusy = false
                state.isDirty = false

                if state.isExiting {
                    return .run { _ in await dismiss() }
                } else {
                    return .none
                }
            case .failure(let error):
                state.isExiting = false
                return handleError(&state, error: error)
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
