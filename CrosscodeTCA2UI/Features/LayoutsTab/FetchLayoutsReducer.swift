import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct FetchLayoutsReducer {
    typealias State = LayoutsTabFeature.State
    @Dependency(\.apiClient) var apiClient
    
    @CasePathable
    enum Action {
        case api(API)
        case `internal`(Internal)
        case delegate(Delegate)
        
        @CasePathable
        enum API {
            case start
        }
        
        @CasePathable
        enum Internal {
            case success([Layout])
        }
        
        
        @CasePathable
        enum Delegate {
            case noLayoutsLoaded
            case failure(Error)
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

extension FetchLayoutsReducer {
    func handleAPIAction(_ state: inout State, _ action: Action.API) -> Effect<Action> {
        switch action {
            case .start:
                return fetchAll(&state)
        }
    }
    
    private func fetchAll(_ state: inout LayoutsTabFeature.State) -> Effect<Action> {
        @Dependency(\.apiClient) var apiClient
        return .run { send in
            do {
                let layouts = try await apiClient.layoutsAPI.fetchAllLevels() as! [Layout]
                
                if layouts.isEmpty {
                    await send(.delegate(.noLayoutsLoaded))
                }
                
                await send(.internal(.success(layouts)))
            }
            catch {
                await send(.delegate(.failure(error)))
            }
        }
    }
}

extension FetchLayoutsReducer {
    func handleInternalAction(_ state: inout State, _ action: Action.Internal) -> Effect<Action> {
        switch action {
            case let .success(layouts):
                state.layouts = IdentifiedArray(uniqueElements: layouts)
                return .none
        }
    }
}
