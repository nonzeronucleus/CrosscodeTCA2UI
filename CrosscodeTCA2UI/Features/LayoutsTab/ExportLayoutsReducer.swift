import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary



@Reducer
struct ExportLayoutsReducer {
    typealias State = LayoutsTabFeature.State
    @Dependency(\.apiClient) var apiClient
    
    @CasePathable
    enum Action: Equatable {
        case api(API)
        case `internal`(Internal)
        case delegate(Delegate)
        
        @CasePathable
        enum API : Equatable {
            case start
        }

        @CasePathable
        enum Internal : Equatable {
            case success
        }
        
        @CasePathable
        enum Delegate : Equatable {
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

extension ExportLayoutsReducer {
    func handleAPIAction(_ state: inout State, _ action: Action.API) -> Effect<Action> {
        switch action {
            case .start:
                return exportLayouts(&state)
        }
    }
    
    private func exportLayouts(_ state: inout LayoutsTabFeature.State) -> Effect<Action> {
        return .run { send in
            do {
                try await apiClient.layoutsAPI.exportLayouts()
                
                await send(.internal(.success))
            }
            catch {
                await send(.delegate(.failure(EquatableError(error))))
            }
        }
    }
}

extension ExportLayoutsReducer {
    func handleInternalAction(_ state: inout State, _ action: Action.Internal) -> Effect<Action> {
        switch action {
            case .success:
                return .none
        }
    }
}
