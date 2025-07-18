import ComposableArchitecture
import Foundation
import CrosscodeDataLibrary



@Reducer
struct ExportGameLevelsReducer {
    typealias State = GameLevelsTabFeature.State

    @Dependency(\.apiClient) var apiClient
    
    enum Action: Equatable {
        case api(API)
        case `internal`(Internal)
        case delegate(Delegate)

        @CasePathable
        enum API: Equatable {
            case start
        }
        
        @CasePathable
        enum Internal: Equatable {
            case success
        }

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

extension ExportGameLevelsReducer {
    func handleAPIAction(_ state: inout State, _ action: Action.API) -> Effect<Action> {
        switch action {
            case .start:
                return exportGameLevels(&state)
        }
    }
    
    private func exportGameLevels(_ state: inout GameLevelsTabFeature.State) -> Effect<Action> {
        return .run { send in
            do {
                try await apiClient.gameLevelsAPI.exportGameLevels()
                
                await send(.internal(.success))
            }
            catch {
                await send(.delegate(.failure(EquatableError(error))))
            }
        }
    }
}

    
    // MARK: Internal Actions
extension ExportGameLevelsReducer {
    func handleInternalAction(_ state: inout State, _ action: Action.Internal) -> Effect<Action> {
        switch action {
            case .success:
                return .none
        }
    }
}


