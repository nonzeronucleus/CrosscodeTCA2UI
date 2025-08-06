import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct LayoutsTabFeature {
    @Dependency(\.uuid) var uuid
    

    @ObservableState
    struct State: Equatable, ErrorHandling {
        var layouts: IdentifiedArrayOf<Layout> = []
        @Presents var editLayout: EditLayoutFeature.State?
        var isBusy: Bool = false
        var error: EquatableError?
    }
    
    @CasePathable
    enum Action {
        case view(View)
        case delegate(Delegate)

        case addLayout(AddLayoutReducer<LayoutsTabFeature>.Action)
        case fetchLayouts(FetchLayoutsReducer.Action)
        case deleteLayout(DeleteLayoutsReducer.Action)
        case editLayout(PresentationAction<EditLayoutFeature.Action>)
        case importLayouts(ImportLayoutsReducer.Action)
        case exportLayouts(ExportLayoutsReducer.Action)
        
        case failure(Error)
        
        @CasePathable
        enum View {
            case pageLoaded
            case itemSelected(UUID)
            case deleteButtonPressed(UUID)
            case exportButtonPressed
            case importButtonPressed
        }
        
        @CasePathable
        enum Delegate {
            case settingsButtonPressed
        }
    }
    
    
    var body: some Reducer<State, Action> {
        Scope(state: \.self, action: \.addLayout) { AddLayoutReducer() }
        Scope(state: \.self, action: \.fetchLayouts) { FetchLayoutsReducer() }
        Scope(state: \.self, action: \.deleteLayout) { DeleteLayoutsReducer() }
        Scope(state: \.self, action: \.importLayouts) { ImportLayoutsReducer() }
        Scope(state: \.self, action: \.exportLayouts) { ExportLayoutsReducer() }

        Reduce { state, action in
            switch action {
                case .view(let viewAction):
                    return handleViewAction(&state, viewAction)
                    
                case .editLayout(.dismiss):
                    // Update item in list with new layout after editing
                    guard let editLayout = state.editLayout else { return .none }
                    guard let layout = editLayout.level else { return .none }

                    state.layouts[id: editLayout.layoutID] = layout
                    return .none
                    
                case let .addLayout(.delegate(delegateAction)):
                    return handleAddLayoutDelegate(&state, delegateAction)
                    
                case let .fetchLayouts(.delegate(delegateAction)):
                    return handleFetchLayoutDelegate(&state, delegateAction)
                    
                case let .deleteLayout(.delegate(delegateAction)):
                    return handleDeleteLayoutDelegate(&state, delegateAction)
                    
                case let .exportLayouts(.delegate(delegateAction)):
                    return handleExportLayoutsDelegate(&state, delegateAction)

                case let .importLayouts(.delegate(delegateAction)):
                    return handleImportLayoutsDelegate(&state, delegateAction)
                    
                case let .editLayout(.presented(.delegate(delegateAction))):
                    return handleEditLayoutDelegate(&state, delegateAction)

                case .addLayout, .fetchLayouts, .deleteLayout, .editLayout, .exportLayouts, .importLayouts:
                    return .none
                case .delegate(_):
                    return .none
                case .failure(let error):
                    state.error = EquatableError(error)
                    return .none
            }
        }
        .ifLet(\.$editLayout, action: \.editLayout) {
            EditLayoutFeature()
        }
    }
    
    private func handleAddLayoutDelegate(_ state: inout State,_ action: AddLayoutReducer<LayoutsTabFeature>.Action.Delegate) -> Effect<Action> {
        switch action {
            case .success:
                return .send(Action.fetchLayouts(.api(.start)))
            case .failure(let error):
                return handleError(&state, error: error)
        }
    }
    
    private func handleFetchLayoutDelegate(_ state: inout State,_ action: FetchLayoutsReducer.Action.Delegate) -> Effect<Action> {
        switch action {
            case .noLayoutsLoaded:
                return .send(.importLayouts(.api(.start)))

            case .failure(let error):
                return handleError(&state, error: error)
        }
    }
    
    private func handleDeleteLayoutDelegate(_ state: inout State,_ action: DeleteLayoutsReducer.Action.Delegate) -> Effect<Action> {
        switch action {
            case .success:
                return .send(Action.fetchLayouts(.api(.start)))
            case .failure(let error):
                return handleError(&state, error: error)
        }
    }
    
    private func handleExportLayoutsDelegate(_ state: inout State,_ action: ExportLayoutsReducer.Action.Delegate) -> Effect<Action> {
            handleChildFailure(&state, action, errorCase: \.failure)
    }
    
    private func handleImportLayoutsDelegate(_ state: inout State,_ action: ImportLayoutsReducer.Action.Delegate) -> Effect<Action> {
        switch action {
            case .failure(let error):
                return handleError(&state, error: error)
        }
    }

    
    private func handleEditLayoutDelegate(_ state: inout State,_ action: EditLayoutFeature.Action.Delegate) -> Effect<Action> {
        switch action {
            case .layoutAdded:
                return .send(Action.fetchLayouts(.api(.start)))
            case .shouldDismiss:
                return .none
        }
    }

    func handleError(_ state: inout State, error: Error) -> Effect<Action> {
        state.error = EquatableError(error)
        state.isBusy = false
        debugPrint("Error: \(error.localizedDescription)")
        return .none
    }
}


    // MARK: - Action Handlers
private extension LayoutsTabFeature {
    // MARK: View Actions
    func handleViewAction(_ state: inout State, _ action: Action.View) -> Effect<Action> {
        switch action {
            case .pageLoaded:
                return .send(.fetchLayouts(.api(.start)))
                
            case .itemSelected(let id):
                state.editLayout = EditLayoutFeature.State(layoutID: id)
                return .none
                
            case .deleteButtonPressed(let id):
                return .send(.deleteLayout(.api(.start(id))))
                
            case .importButtonPressed:
                return .send(.importLayouts(.api(.start)))
                
            case .exportButtonPressed:
                return .send(.exportLayouts(.api(.start)))
        }
    }
}
