import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct LayoutsListFeature {
    @Dependency(\.uuid) var uuid

    @ObservableState
    struct State: Equatable {
        var layouts: [Layout] = []
        var error: LayoutError?
    }
    
    enum Action: Equatable {
        case addLayout(AddLayout)
        case fetchAll(FetchAll)
        
        enum AddLayout: Equatable {
            case start
            case success
            case failure(LayoutError)
        }
        
        enum FetchAll: Equatable {
            case start
            case success([Layout])
            case failure(LayoutError)
        }
    }
    
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                case .addLayout(let subAction):
                    return handleAddLayout(&state, action: subAction)
                case .fetchAll(let subAction):
                    return handleFetchAll(&state, action: subAction)
            }
        }
    }
}


// Add Layout

extension LayoutsListFeature {
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
                await send(.fetchAll(.failure(error as! LayoutError)))
            }
        }
    }
    
    private func handleAddLayoutSuccess(_ state: inout State) -> Effect<Action> {
        .send(Action.fetchAll(.start))
    }
}



// Fetch all layouts

extension LayoutsListFeature {
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
            catch let error as LayoutError {
                await send(.fetchAll(.failure(error)))
            }
            catch {
                await send(.fetchAll(.failure(.wrappedError(error.localizedDescription)))) // Fallback
            }
        }
    }
}

enum LayoutError: Error, Equatable {
    case networkUnavailable
    case invalidData
    case wrappedError(String)
}


