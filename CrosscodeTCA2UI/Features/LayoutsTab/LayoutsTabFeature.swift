import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct LayoutsTabFeature {
    @Dependency(\.uuid) var uuid

    @ObservableState
    struct State: Equatable {
        var layouts: IdentifiedArrayOf<Layout> = []
        @Presents var editLayout: EditLayoutFeature.State?
        var isBusy: Bool = false
        var error: EquatableError?
    }
    
    enum Action: Equatable {
        case pageLoaded
        case itemSelected(UUID)
        case deleteButtonPressed(UUID)

        case addLayout(AddLayoutReducer.Action)
        case fetchLayouts(FetchLayoutsReducer.Action)
        case deleteLayout(DeleteLayout)
        case editLayout(PresentationAction<EditLayoutFeature.Action>)
        case failure(EquatableError)
        case success
        
        enum DeleteLayout: Equatable {
            case start(UUID)
            case success
        }
    }
    
    
    var body: some Reducer<State, Action> {
        Scope(state: \.self, action: \.addLayout) { AddLayoutReducer() }
        Scope(state: \.self, action: \.fetchLayouts) { FetchLayoutsReducer() }

        Reduce { state, action in
            switch action {
                case .pageLoaded:
                    return .send(.fetchLayouts(.start))
                    
                case .itemSelected(let id):
                    state.editLayout = EditLayoutFeature.State(layoutID: id)
                    return .none
                    
                case .failure(let error):
                    if let wrappedError = error.wrappedError as? EquatableError {
                        state.error = wrappedError
                    }
                    else {
                        state.error = error
                    }
                    return .none
                    
                case .deleteButtonPressed(let id):
                    return .send(.deleteLayout(.start(id)))
                    
                case .deleteLayout(let subAction):
                    return handleDelete(&state, action: subAction)
                    
                case .editLayout(.dismiss):
                    // Update item in list with new layout after editing
                    guard let editLayout = state.editLayout else { return .none }
                    guard let layout = editLayout.layout else { return .none }

                    state.layouts[id: editLayout.layoutID] = layout
                    return .none
                    
                case let .addLayout(.delegate(delegateAction)):
                    return handleAddLayoutDelegate(&state, delegateAction)
                    
                case let .fetchLayouts(.delegate(delegateAction)):
                    return handleFetchLayoutDelegate(&state, delegateAction)
                    
                case .editLayout:
                    return .none
                    
                case .success:
                    return .none
                    
                case .addLayout, .fetchLayouts:
                    return .none
            }
        }
        .ifLet(\.$editLayout, action: \.editLayout) {
            EditLayoutFeature()
        }
    }
    
    private func handleAddLayoutDelegate(_ state: inout State,_ action: AddLayoutReducer.Action.Delegate) -> Effect<Action> {
        switch action {
            case .success:
                return .send(Action.fetchLayouts(.start))
            case .failure(let error):
                return handleError(&state, error: error)
        }
    }
    
    private func handleFetchLayoutDelegate(_ state: inout State,_ action: FetchLayoutsReducer.Action.Delegate) -> Effect<Action> {
        switch action {
            case .failure(let error):
                return handleError(&state, error: error)
        }
    }

    
    func handleError(_ state: inout State, error: EquatableError) -> Effect<Action> {
        state.error = error
        state.isBusy = false
        return .none
    }
}


// Delete layout

extension LayoutsTabFeature {
    private func handleDelete(_ state: inout State, action:Action.DeleteLayout) -> Effect<Action> {
        switch action {
            case .start(let id):
                return deleteLayout(&state, id: id)
                
            case .success:
                return .send(Action.fetchLayouts(.start))
        }
    }
    
    private func deleteLayout(_ state: inout State, id:UUID) -> Effect<Action> {
        @Dependency(\.apiClient) var apiClient
        return .run { send in
            do {
                try await apiClient.layoutsAPI.deleteLevel(id: id, )

                await send(.fetchLayouts(.start))
            }
            catch {
                await send(.failure(EquatableError(error)))
            }
        }
    }
}

