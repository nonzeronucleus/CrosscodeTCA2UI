import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary
import CasePaths

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
        var isBusy = false
        var isDirty = false
        var isPopulated = false
        var isExiting = false
        var error: EquatableError?
    }
    
    // MARK: - Actions
    enum Action: Equatable {
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
        
        enum View:Equatable {
            case pageLoaded
            case backButtonTapped
            case duplicateButtonTapped
            case exportButtonPressed
            case cancelButtonTapped
        }
        
        enum Internal:Equatable {
            case failure(EquatableError)
        }
        
        enum Delegate:Equatable {
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
                    
                case .loadLayout(.delegate(let action)):
                    return handleLoadLayoutDelegate(&state, action)
                    
                case .saveLayout(.delegate(let action)):
                    return handleSaveLayoutDelegate(&state, action)
                    
                case .createGameLevel(.delegate(let action)):
                    return handleCreateGameLevelDelegate(&state, action)
                    
                case .cell(.delegate(let action)):
                    let ret = handleCellDelegate(&state, action)
                    debugPrint(state.error)
                    return ret
                    
                case .populate(.delegate(let action)):
                    return handlePopulationDelegate(&state, action)
                    
                case .depopulate(.delegate(let action)):
                    return handleDepopulationDelegate(&state, action)
                    
                    // Non-delegate child actions
                case .addLayout, .loadLayout, .saveLayout,
                        .createGameLevel, .populate,
                        .depopulate, .cell:
                    return .none
            }
        }
    }
}

// MARK: - Error Handling Protocol
protocol ErrorHandling {
    var error: EquatableError? { get set }
    var isBusy: Bool { get set }
    var isExiting: Bool { get set }
}

// MARK: - Action Handlers
private extension EditLayoutFeature {
    // MARK: View Actions
    func handleViewAction(_ state: inout State, _ action: Action.View) -> Effect<Action> {
        switch action {
        case .pageLoaded:
            return .send(.loadLayout(.start(state.layoutID)))
            
        case .backButtonTapped:
            return handleBackButton(&state)
            
        case .duplicateButtonTapped:
            return .send(.addLayout(.start(state.layout?.gridText)))
            
        case .exportButtonPressed:
            return .send(.createGameLevel(.api(.start)))
            
        case .cancelButtonTapped:
            return .send(.populate(.cancel))
        }
    }
    
    func handleBackButton(_ state: inout State) -> Effect<Action> {
        guard isPresented else { return .none }
        state.isExiting = true
        return state.isPopulated ? .run { _ in await dismiss() } : .send(.saveLayout(.start))
    }
    
    // MARK: Internal Actions
    func handleInternalAction(_ state: inout State, _ action: Action.Internal) -> Effect<Action> {
        switch action {
        case .failure(let error):
            state.error = error
            state.isBusy = false
            return .none
        }
    }
    
    // MARK: Generic Delegate Handlers
    func handleAddLayoutDelegate(_ state: inout State, _ action: AddLayoutReducer<Self>.Action.Delegate) -> Effect<Action> {
        handleChildDelegate(
            &state,
            action,
            successCase: \.success,
            failureCase: \.failure
        ) { _, state in
            .send(.delegate(.layoutAdded))
        }
    }
    
    func handleSaveLayoutDelegate(_ state: inout State, _ action: SaveLayoutReducer.Action.Delegate) -> Effect<Action> {
        handleChildDelegate(
            &state,
            action,
            successCase: \.success,
            failureCase: \.failure
        ) { _, state in
            state.isBusy = false
            state.isDirty = false
            return state.isExiting ? .run { _ in await dismiss() } : .none
        }
    }
    
    func handleCreateGameLevelDelegate(_ state: inout State, _ action: CreateGameLevelReducer.Action.Delegate) -> Effect<Action> {
        handleChildDelegate(
            &state,
            action,
            successCase: \.success,
            failureCase: \.failure
        ) { _, state in
            state.isBusy = false
            state.isDirty = false
            return state.isExiting ? .run { _ in await dismiss() } : .none
        }
    }
    
    // MARK: Pure Error Handlers
    func handleLoadLayoutDelegate(_ state: inout State, _ action: LoadLayoutReducer.Action.Delegate) -> Effect<Action> {
        handleChildFailure(&state, action, errorCase: \.failure)
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

// MARK: - Reducer Extensions
extension Reducer where State: ErrorHandling {
    func handleChildFailure<Child: CasePathable>(
        _ state: inout State,
        _ action: Child,
        errorCase: CaseKeyPath<Child, EquatableError>
    ) -> Effect<Action> {
        guard let error = action[case: errorCase] else { return .none }
        state.error = error
        state.isBusy = false
        state.isExiting = false
        return .none
    }
    
    func handleChildDelegate<Child: CasePathable, Success>(
        _ state: inout State,
        _ action: Child,
        successCase: CaseKeyPath<Child, Success>,
        failureCase: CaseKeyPath<Child, EquatableError>,
        onSuccess: (Success, inout State) -> Effect<Action>
    ) -> Effect<Action> {
        if let success = action[case: successCase] {
            return onSuccess(success, &state)
        }
        
        if let error = action[case: failureCase] {
            var state = state
            state.error = error
            state.isBusy = false
            state.isExiting = false
            return .none
        }
        
        return .none
    }
}

private extension EditLayoutFeature {
    func dismissEffect() -> Effect<Action> {
        .run { _ in await dismiss() }
    }
}

//import ComposableArchitecture
//import Foundation
//import CrosscodeDataLibrary
//import CasePaths
//
//@Reducer
//struct EditLayoutFeature {
//    @Dependency(\.uuid) var uuid
//    @Dependency(\.dismiss) var dismiss
//    @Dependency(\.isPresented) var isPresented
//
//    @ObservableState
//    struct State: Equatable {
//        var settings = Settings()
//        var layoutID: UUID
//        var layout: Layout?
//        var isBusy = false
//        var isDirty = false
//        var isPopulated: Bool = false
//        var isExiting: Bool = false
//        var error: EquatableError?
//    }
//
//    enum Action: Equatable {
//        case view(View)
//        case `internal`(Internal)
//        case delegate(Delegate)
//        case addLayout(AddLayoutReducer<EditLayoutFeature>.Action)
//        case loadLayout(LoadLayoutReducer.Action)
//        case saveLayout(SaveLayoutReducer.Action)
//        case createGameLevel(CreateGameLevelReducer.Action)
//        case populate(PopulationReducer.Action)
//        case depopulate(DepopulationReducer.Action)
//        case cell(EditLayoutCellReducer.Action)
//        
//        enum View: Equatable {
//            case pageLoaded
//            case backButtonTapped
//            case duplicateButtonTapped
//            case exportButtonPressed
//            case cancelButtonTapped
//        }
//        enum Internal : Equatable {
//            case failure(EquatableError)
//        }
//        enum Delegate : Equatable {
//            case laypoutAdded
//        }
//    }
//    
//    var body: some Reducer<State, Action> {
//        Scope(state: \.self, action: \.addLayout) { AddLayoutReducer() }
//        Scope(state: \.self, action: \.loadLayout) { LoadLayoutReducer() }
//        Scope(state: \.self, action: \.saveLayout) { SaveLayoutReducer() }
//        Scope(state: \.self, action: \.cell) { EditLayoutCellReducer() }
//        Scope(state: \.self, action: \.populate) { PopulationReducer() }
//        Scope(state: \.self, action: \.depopulate) { DepopulationReducer() }
//        Scope(state: \.self, action: \.createGameLevel) {CreateGameLevelReducer()}
//        
//        Reduce { state, action in
//            switch action {
//                case let .view(viewAction):
//                    return handleViewAction(&state, viewAction)
//
//                case let .internal(internalAction):
//                    switch internalAction {
//                        case .failure(let error):
//                            return handleError(&state, error: error)
//                    }
//                    
//                case let .addLayout(.delegate(delegateAction)):
//                    return handleAddLayoutDelegate(&state, delegateAction)
//                    
//                case let .loadLayout(.delegate(action)):
//                    return handleLoadLayoutDelegate(&state, action)
//                    
//                case let .saveLayout(.delegate(action)):
//                    return handleSaveLayoutDelegate(&state, action)
//                    
//                case let .createGameLevel(.delegate(action)):
//                    return handleCreateGameLevelDelegate(&state, action)
//
//                case let .cell(.delegate(action)):
//                    return handleCellDelegate(&state, action)
//
//                case let .populate(.delegate(action)):
//                    return handlePopulationDelegate(&state, action)
//
//                case let .depopulate(.delegate(action)):
//                    return handleDepopulationDelegate(&state, action)
//
//                case .addLayout, .saveLayout, .createGameLevel, .populate, .depopulate, .loadLayout, .cell, .delegate:
//                    return .none
//            }
//        }
//    }
//    
//    func handleViewAction(_ state: inout State, _ action: Action.View) -> Effect<Action> {
//        switch action {
//            case .pageLoaded:
//                return handlePageLoaded(&state)
//            case .backButtonTapped:
//                return handleBackButton(&state)
//            case .exportButtonPressed:
//                return handleExportButton(&state)
//                
//            case .duplicateButtonTapped:
//                return handleDuplicateButton(&state)
//                
//            case .cancelButtonTapped:
//                return handleCancelButton(&state)
//        }
//    }
//    
//    func handlePageLoaded(_ state: inout State) -> Effect<Action> {
//        return .send(.loadLayout(.start(state.layoutID)))
//    }
//    
//    func handleExportButton(_ state: inout State) -> Effect<Action> {
//        return .send(.createGameLevel(.api(.start)))
//    }
//    
//    func handleDuplicateButton(_ state: inout State) -> Effect<Action> {
//        return .send(.addLayout(.start(state.layout?.gridText)))
//    }
//
//    func handleCancelButton(_ state: inout State) -> Effect<Action> {
//        return .send(.populate(.cancel))
////        return .none
////        return .send(.addLayout(.start(state.layout?.gridText)))
//    }
//
//    
//    func handleBackButton(_ state: inout State) -> Effect<Action> {
//        if isPresented {
//            state.isExiting = true
//            if state.isPopulated {
//                return .run { _ in await dismiss() }
//            }
//
//            return .send(.saveLayout(.start))
//        } else {
//            return .none
//        }
//    }
//    
//    private func handleAddLayoutDelegate(_ state: inout State,_ action: AddLayoutReducer<Self>.Action.Delegate) -> Effect<Action> {
//        switch action {
//            case .success:
////                return .none
//                return .send(Action.delegate(.laypoutAdded))
//            case .failure(let error):
//                return handleError(&state, error: error)
//        }
//    }
//    
//    
//    private func handleLoadLayoutDelegate(_ state: inout State,_ action: LoadLayoutReducer.Action.Delegate) -> Effect<Action> {
//        switch action {
//            case .failure(let error):
//                return handleError(&state, error: error)
//        }
//    }
//
//    private func handleCellDelegate(_ state: inout State,_ action: EditLayoutCellReducer.Action.Delegate) -> Effect<Action> {
//        switch action {
//            case .failure(let error):
//                return handleError(&state, error: error)
//        }
//    }
//
//    private func handlePopulationDelegate(_ state: inout State,_ action: PopulationReducer.Action.Delegate) -> Effect<Action> {
//        switch action {
//            case .failure(let error):
//                return handleError(&state, error: error)
//        }
//    }
//    
////
//    
////    func handlePopulationDelegate(_ state: inout State, _ action: PopulationReducer.Action.Delegate) -> Effect<Action> {
////        handleAnyFailure(
////            &state,
////            action,
////            errorCasePath: .failure
////        )
////    }
//    
//    private func handleDepopulationDelegate(_ state: inout State,_ action: DepopulationReducer.Action.Delegate) -> Effect<Action> {
//        return handleStandardDelegate(&state, action, onSuccess: {_ in })
//    }
////        switch action {
////            case .failure(let error):
////                return handleError(&state, error: error)
////        }
////    }
//    
//    
//    private func handleCreateGameLevelDelegate(_ state: inout State,_ action: CreateGameLevelReducer.Action.Delegate) -> Effect<Action> {
//        switch action {
//            case .success:
//                state.isBusy = false
//                state.isDirty = false
//
//                if state.isExiting {
//                    return .run { _ in await dismiss() }
//                } else {
//                    return .none
//                }
//            case .failure(let error):
//                state.isExiting = false
//                return handleError(&state, error: error)
//        }
//    }
//    
//    
//    private func handleChildFailure<Child: CasePathable>(
//        _ state: inout EditLayoutFeature.State,
//        _ action: Child,
//        errorCase: CaseKeyPath<Child, EquatableError>
//    ) -> Effect<EditLayoutFeature.Action> {
//        guard let error = action[case: errorCase] else { return .none }
//        
//        state.error = error
//        state.isBusy = false
//        return .none
//    }
//
//
//    func handleSaveDelegate(
//        _ state: inout State,
//        _ action: SaveLayoutReducer.Action.Delegate
//    ) -> Effect<Action> {
//        handleChildFailure(&state, action, errorCase: \.failure)
//    }
//    
////    private func handleSaveLayoutDelegate(_ state: inout State,_ action: SaveLayoutReducer.Action.Delegate) -> Effect<Action> {
////        switch action {
////            case .success:
////                state.isBusy = false
////                state.isDirty = false
////
////                if state.isExiting {
////                    return .run { _ in await dismiss() }
////                } else {
////                    return .none
////                }
////            case .failure(let error):
////                state.isExiting = false
////                return handleError(&state, error: error)
////        }
////    }
////
//    
//    private func handleSaveLayoutDelegate(
//        _ state: inout State,
//        _ action: SaveLayoutReducer.Action.Delegate
//    ) -> Effect<Action> {
//        handleStandardDelegate(&state, action) { state in
//            state.isBusy = false
//            state.isDirty = false
//            return state.isExiting ? .run { _ in await dismiss() } : .none
//        }
//    }
//    
//    private func handleStandardDelegate(
//        _ state: inout State,
//        _ action: SaveLayoutReducer.Action.Delegate,
//        onSuccess: (inout State) -> Effect<Action>
//    ) -> Effect<Action> {
//        switch action {
//            case .success:
//                return onSuccess(&state)
//                
//            case .failure(let error):
//                state.isExiting = false
//                state.error = error
//                state.isBusy = false
//                return .none
//        }
//    }
//
//
//    
//    func handleError(_ state: inout State, error: EquatableError) -> Effect<Action> {
//        state.error = error
//        state.isBusy = false
//        return .none
//    }
//    
//    private func handleAnyFailure<ChildAction>(
//        _ state: inout State,
//        _ childAction: ChildAction,
//        errorCasePath: AnyCasePath<ChildAction, EquatableError>
//    ) -> Effect<Action> {
//        guard let error = errorCasePath.extract(from: childAction) else { return .none }
//        
//        state.error = error
//        state.isBusy = false
//        return .none
//    }
//}
//
//
public enum EditLayoutError: Error {
    case loadLayoutError
    case saveLayoutError(_ text:String)
    case handlePopulationError(_ text:String)
}
//
//
