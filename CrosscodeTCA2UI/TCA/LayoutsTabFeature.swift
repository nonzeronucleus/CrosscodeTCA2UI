import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct LayoutsTabFeature {
    @Dependency(\.uuid) var uuid

    @ObservableState
    struct State: Equatable {
        var layouts: [Layout] = []
        @Presents var editLayout: EditLayoutFeature.State?
        var error: EquatableError?
    }
    
    enum Action: Equatable {
        case pageLoaded
        case itemSelected(UUID)

        case addLayout(AddLayout)
        case fetchAll(FetchAll)
        case editLayout(PresentationAction<EditLayoutFeature.Action>)
        
        enum AddLayout: Equatable {
            case start
            case success
            case failure(EquatableError)
        }
        
        enum FetchAll: Equatable {
            case start
            case success([Layout])
            case failure(EquatableError)
        }
    }
    
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                case .pageLoaded:
                    return .send(.fetchAll(.start))
                case .itemSelected(let id):
                    state.editLayout = EditLayoutFeature.State(layoutID: id)
                    return .none
                case .addLayout(let subAction):
                    return handleAddLayout(&state, action: subAction)
                case .fetchAll(let subAction):
                    return handleFetchAll(&state, action: subAction)
                case .editLayout(_):
                    return .none
            }
        }
        .ifLet(\.$editLayout, action: \.editLayout) {
            EditLayoutFeature()
        }
    }
}


// Add Layout

extension LayoutsTabFeature {
    private func handleAddLayout(_ state: inout State, action:Action.AddLayout) -> Effect<Action> {
        switch action {
            case .start:
                return addLayout(&state)
                
            case .success:
                return handleAddLayoutSuccess(&state)
                
            case .failure(let error):
                state.error = error
                return .none
        }
    }
    
    private func addLayout(_ state: inout State) -> Effect<Action> {
        @Dependency(\.apiClient) var apiClient
        return .run { send in
            do {
                try await apiClient.layoutsAPI.addNewLayout()
                
                await send(.addLayout(.success))
            }
            catch {
                await send(.fetchAll(.failure(error as! EquatableError)))
            }
        }
    }
    
    private func handleAddLayoutSuccess(_ state: inout State) -> Effect<Action> {
        .send(Action.fetchAll(.start))
    }
}



// Fetch all layouts

extension LayoutsTabFeature {
    private func handleFetchAll(_ state: inout State, action:Action.FetchAll) -> Effect<Action> {
        switch action {
            case .start:
                return fetchAll(&state)
                
            case .success(let layouts):
                state.layouts = layouts
                return .none
                
            case .failure(let error):
                debugPrint("Error: \(error)")
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
            catch let error as EquatableError {
                await send(.fetchAll(.failure(error)))
            }
            catch {
                await send(.fetchAll(.failure(EquatableError(error)))) // Fallback
            }
        }
    }
}
