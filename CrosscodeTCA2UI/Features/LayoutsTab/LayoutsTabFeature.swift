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
        case fetchAll(FetchAll)
        case deleteLayout(DeleteLayout)
        case editLayout(PresentationAction<EditLayoutFeature.Action>)
        case failure(EquatableError)
        case success
        
        enum FetchAll: Equatable {
            case start
            case success([Layout])
        }
        
        enum DeleteLayout: Equatable {
            case start(UUID)
            case success
        }
    }
    
    
    var body: some Reducer<State, Action> {
        Scope(state: \.self, action: \.addLayout) { AddLayoutReducer() }

        Reduce { state, action in
            switch action {
                case .pageLoaded:
                    return .send(.fetchAll(.start))
                    
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
                    
                case .fetchAll(let subAction):
                    return handleFetchAll(&state, action: subAction)
                    
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
                    
                case .editLayout:
                    return .none
                    
                case .success:
                    return .none
                    
                case .addLayout:
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
                return .send(Action.fetchAll(.start))
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

// Fetch all layouts

extension LayoutsTabFeature {
    private func handleFetchAll(_ state: inout State, action:Action.FetchAll) -> Effect<Action> {
        switch action {
            case .start:
                return fetchAll(&state)
                
            case .success(let layouts):
                state.layouts = IdentifiedArray(uniqueElements: layouts)
//                state.layouts = layouts
                return .none
        }
    }
    
    private func fetchAll(_ state: inout State) -> Effect<Action> {
        @Dependency(\.apiClient) var apiClient
        return .run { send in
            do {
                let result = try await apiClient.layoutsAPI.fetchAllLevels() as! [Layout]

                await send(.fetchAll(.success(result)))
            }
            catch {
                await send(.failure(EquatableError(error)))
            }
        }
    }
}


// Delete layout

extension LayoutsTabFeature {
    private func handleDelete(_ state: inout State, action:Action.DeleteLayout) -> Effect<Action> {
        switch action {
            case .start(let id):
                return deleteLayout(&state, id: id)
                
            case .success:
                return .send(Action.fetchAll(.start))
        }
    }
    
    private func deleteLayout(_ state: inout State, id:UUID) -> Effect<Action> {
        @Dependency(\.apiClient) var apiClient
        return .run { send in
            do {
                try await apiClient.layoutsAPI.deleteLevel(id: id, )

                await send(.fetchAll(.start))
            }
            catch {
                await send(.failure(EquatableError(error)))
            }
        }
    }
}

