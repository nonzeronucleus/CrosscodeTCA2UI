import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary

@Reducer
struct ImportLayoutsReducer {
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

extension ImportLayoutsReducer {
    func handleAPIAction(_ state: inout State, _ action: Action.API) -> Effect<Action> {
        switch action {
            case .start:
                return importLayouts(&state)
        }
    }
    
    private func importLayouts(_ state: inout LayoutsTabFeature.State) -> Effect<Action> {
        return .run { send in
            do {
                let layouts = try await apiClient.layoutsAPI.importLayouts()
                
                await send(.internal(.success(layouts)))
            }
            catch {
                await send(.delegate(.failure(error)))
            }
        }
    }
}

extension ImportLayoutsReducer {
    func handleInternalAction(_ state: inout State, _ action: Action.Internal) -> Effect<Action> {
        switch action {
            case let .success(layouts):
                state.layouts = IdentifiedArrayOf(uniqueElements: layouts)
                return .none
        }
    }
}


