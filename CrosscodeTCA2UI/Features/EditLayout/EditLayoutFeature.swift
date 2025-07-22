import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary
import CasePaths



private protocol ErrorHandlingResult {
    var error: (any Error)? { get }
}

extension TaskResult: ErrorHandlingResult {
    var error: Error? {
        guard case .failure(let error) = self else { return nil }
        return error
    }
}
private extension EditLayoutFeature {
    func checkDelegateError(_ state: inout State, _ delegateAction: some Any) {
        let mirror = Mirror(reflecting: delegateAction)
        for child in mirror.children {
            if let result = child.value as? any ErrorHandlingResult {
                if let error = result.error {
                    state.error = EquatableError(error)
                }
            }
        }
    }
}


@Reducer
struct EditLayoutFeature {
    // MARK: - Dependencies
    @Dependency(\.uuid) var uuid
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.isPresented) var isPresented
    
    // MARK: - State
    @ObservableState
    struct State: Equatable, ErrorHandling {
        var settings = Settings()
        var layoutID: UUID
        var layout: Layout?
        var isDirty = false
        var isPopulated = false
        var isExiting = false
        var isBusy = false
        var error: EquatableError?
    }
    
    // MARK: - Actions
    @CasePathable
    enum Action {
        case view(View)
        case `internal`(Internal)
        case delegate(Delegate)
        
        // Child reducers
        case addLayout(AddLayoutReducer<EditLayoutFeature>.Action)
        case loadLayout(LoadLayoutReducer.Action)
        case saveLayout(SaveLayoutReducer.Action)
        case createGameLevel(CreateGameLevelReducer.Action)
        case populate(PopulationReducer.Action)
        case depopulate(DepopulationReducer.Action)
        case cell(EditLayoutCellReducer.Action)
        
        @CasePathable
        enum View {
            case pageLoaded
            case backButtonTapped
            case duplicateButtonTapped
            case exportButtonTapped
            case cancelButtonTapped
            case populateButtonTapped
            case depopulateButtonTapped
        }

        @CasePathable
        enum Internal {
            case failure(Error)
        }

        @CasePathable
        enum Delegate {
            case layoutAdded
            case shouldDismiss
        }
    }
    
    // MARK: - Reducer
    var body: some Reducer<State, Action> {
        // Child reducers
        CombineReducers {
            Scope(state: \.self, action: \.addLayout) { AddLayoutReducer() }
            Scope(state: \.self, action: \.loadLayout) { LoadLayoutReducer() }
            Scope(state: \.self, action: \.saveLayout) { SaveLayoutReducer() }
            Scope(state: \.self, action: \.createGameLevel) { CreateGameLevelReducer() }
            Scope(state: \.self, action: \.populate) { PopulationReducer() }
            Scope(state: \.self, action: \.depopulate) { DepopulationReducer() }
            Scope(state: \.self, action: \.cell) { EditLayoutCellReducer() }
        }
        
        // Main reducer
        Reduce { state, action in
            switch action {
                case .view(let viewAction):
                    return handleViewAction(&state, viewAction)
                    
                case .internal(let internalAction):
                    return handleInternalAction(&state, internalAction)
                    
                case .delegate:
                    return .none // Parent handles
                    
                    // Child delegates
                case .addLayout(.delegate(let action)):
                    return handleAddLayoutDelegate(&state, action)
                    
                case .loadLayout(.delegate(let delegateAction)):
                    checkDelegateError(&state, delegateAction)
                    
                    return .none
                    
                case .saveLayout(.delegate(let action)):
                    return handleSaveLayoutDelegate(&state, action)
                    
                case .createGameLevel(.delegate(let action)):
                    return handleCreateGameLevelDelegate(&state, action)
                    
                case .cell(.delegate(let action)):
                    let ret = handleCellDelegate(&state, action)
                    return ret
                    
                case .populate(.delegate(let action)):
                    return handlePopulationDelegate(&state, action)
                    
                case .depopulate(.delegate(let action)):
                    return handleDepopulationDelegate(&state, action)
                    
                    // Non-delegate child actions
                case .addLayout, .loadLayout(.api), .loadLayout(.internal), .saveLayout,
                        .createGameLevel, .populate,
                        .depopulate, .cell:
                    return .none
            }
        }
    }
}

private extension EditLayoutFeature {
    func checkError<Success>(_ state: inout State, _ result: TaskResult<Success>) {
        if case .failure(let error) = result {
            state.error = EquatableError(error)
        }
    }
}

// MARK: - Action Handlers
private extension EditLayoutFeature {
    
    
    // MARK: View Actions
    func handleViewAction(_ state: inout State, _ action: Action.View) -> Effect<Action> {
        switch action {
            case .pageLoaded:
                return .send(.loadLayout(.api(.start(state.layoutID))))
                
            case .backButtonTapped:
                return handleBackButton(&state)
                
            case .duplicateButtonTapped:
                return .send(.addLayout(.api(.start(state.layout?.gridText))))
                
            case .exportButtonTapped:
                return .send(.createGameLevel(.api(.start)))
                
            case .cancelButtonTapped:
                return .send(.populate(.api(.cancel)))
                
            case .populateButtonTapped:
                return .send(.populate(.api(.start)))
                
            case .depopulateButtonTapped:
                return .send(.depopulate(.api(.start)))
        }
    }
    
    func handleBackButton(_ state: inout State) -> Effect<Action> {
        guard isPresented else { return .none }
        state.isExiting = true
        return state.isPopulated ? .run { _ in await dismiss() } : .send(.saveLayout(.api(.start)))
    }
}
    
private extension EditLayoutFeature {
    
    // MARK: Internal Actions
    func handleInternalAction(_ state: inout State, _ action: Action.Internal) -> Effect<Action> {
        switch action {
            case .failure(let error):
                return handleError(&state, error: error)
//            case .handleSuccess(_):
//                return .none
        }
    }
    
    // MARK: Generic Delegate Handlers
    func handleAddLayoutDelegate(_ state: inout State, _ action: AddLayoutReducer<Self>.Action.Delegate) -> Effect<Action> {
        handleChildDelegate( &state, action, successCase: \.success, failureCase: \.failure ) { _, state in
            .send(.delegate(.layoutAdded))
        }
    }
    
    func handleSaveLayoutDelegate(_ state: inout State, _ action: SaveLayoutReducer.Action.Delegate) -> Effect<Action> {
        handleChildDelegate( &state, action, successCase: \.success, failureCase: \.failure,
             onFailure: { _, state in state.isExiting = false }
        ) { _, state in
            state.isBusy = false
            state.isDirty = false
            return state.isExiting ? .run { _ in await dismiss() } : .none
        }
    }
    
    
    
    func handleCreateGameLevelDelegate(_ state: inout State, _ action: CreateGameLevelReducer.Action.Delegate) -> Effect<Action> {
        handleChildDelegate( &state, action, successCase: \.success, failureCase: \.failure )
        { _, state in
            state.isBusy = false
            state.isDirty = false
            return state.isExiting ? .run { _ in await dismiss() } : .none
        }
    }
    
    // MARK: Pure Error Handlers
    func handleLoadLayoutDelegate(_ state: inout State, _ action: LoadLayoutReducer.Action.Delegate) -> Effect<Action> {
//        handleChildFailure(&state, action, errorCase: \.failure)
        return .none
    }
    
    func handleCellDelegate(_ state: inout State, _ action: EditLayoutCellReducer.Action.Delegate) -> Effect<Action> {
        handleChildFailure(&state, action, errorCase: \.failure)
    }
    
    func handlePopulationDelegate(_ state: inout State, _ action: PopulationReducer.Action.Delegate) -> Effect<Action> {
        handleChildFailure(&state, action, errorCase: \.failure)
    }
    
    func handleDepopulationDelegate(_ state: inout State, _ action: DepopulationReducer.Action.Delegate) -> Effect<Action> {
        handleChildFailure(&state, action, errorCase: \.failure)
    }
}

public enum EditLayoutError: Error, Equatable {
    case loadLayoutError
    case saveLayoutError(_ text:String)
    case handlePopulationError(_ text:String)
}

// 119
