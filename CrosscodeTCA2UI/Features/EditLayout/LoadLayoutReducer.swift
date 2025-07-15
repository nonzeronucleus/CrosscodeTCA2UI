import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary


    @Reducer
struct LoadLayoutReducer {
    typealias State = EditLayoutFeature.State
    @Dependency(\.apiClient) var apiClient
    
    @CasePathable
    enum Action: Equatable {
        
        case api(API)
        case `internal`(Internal)
        case delegate(Delegate)
        
        @CasePathable
        enum API:Equatable {
            case start(UUID)
        }
        
        @CasePathable
        enum Internal:Equatable {
            case success(Layout)
        }
        
        @CasePathable enum Delegate : Equatable {
            case failure(EquatableError)
        }
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                case let .api(apiAction):
                    return handleAPIAction(&state, apiAction)
                    
                case let .internal(internalAction):
                    return handleInternalAction(&state, internalAction)
                    
                case .delegate:
                    return .none
            }
        }
    }
}


// MARK: - API
extension LoadLayoutReducer {
    func handleAPIAction(_ state: inout State, _ action: Action.API) -> Effect<Action> {
        switch action {
            case .start(let id):
                state.isBusy = true
                return loadLayout(&state, id:id)
        }
    }
    
    private func loadLayout(_ state: inout EditLayoutFeature.State, id:UUID) -> Effect<Action> {
        return .run { send in
            do {
                let result = try await apiClient.layoutsAPI.fetchLevel(id: id)
                
                if let result = result as? Layout {
                    await send(.internal(.success(result)))
                }
                else {
                    throw EditLayoutError.loadLayoutError
                }
            }
            catch {
                await send(.delegate(.failure(EquatableError(error))))
            }
        }
    }
}

    

// MARK: - Internal Actions
extension LoadLayoutReducer {
    func handleInternalAction(_ state: inout State, _ action: Action.Internal) -> Effect<Action> {
        switch action {
            case .success(let layout):
                state.layout = layout
                state.isBusy = false
                state.isDirty = false
                
                return .none
                
        }
    }
}
